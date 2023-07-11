//
//  CafeSearchCore.swift
//  coffice
//
//  Created by sehooon on 2023/07/03.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import CoreLocation
import Foundation
import Network
import SwiftUI

struct CafeSearchCore: ReducerProtocol {
  struct CancelID: Hashable {}

  enum CafeSearchViewBodyType {
    case recentSearchListView
    case searchResultEmptyView
    case searchResultListView
  }

  struct State: Equatable {
    @BindingState var searchText = ""
    var searchTextSnapshot: String?
    var searchCameraPositionSnapshot: CLLocationCoordinate2D?
    var cafeList: [String] = []
    var stationList: [String] = []
    var recentSearchWordList: [RecentSearchWord] = []
    var previousViewType: CafeMapCore.ViewType = .mainMapView
    var currentBodyType: CafeSearchViewBodyType = .searchResultListView

    // MARK: quickSearch
    var places: [Cafe] = []
    var waypoints: [WayPoint] = []
    var selectedWaypoints: WayPoint?
    /// debounce보다 검색이 먼저 이루어졌는지, CheckFlag
    var timingCheckFlag = false
  }

  enum Action: Equatable, BindableAction {
    case dismiss
    case onAppear
    case submitText
    case clearText
    case requestSearchPlace(String)
    case deleteRecentSearchWord(Int)
    case binding(BindingAction<State>)
    case tappedRecentSearchWord(String)
    case fetchWaypoints(String)
    case requestWaypointSearchPlace(WayPoint)
    case placeCellTapped
    case waypointCellTapped
    case fetchRecentSearchWords
    case fetchPlacesAndWaypoints(String)
    case recentSearchWordsResponse(TaskResult<[RecentSearchWord]>)
    case fetchPlacesAndWaypointsResponse(CafeSearchResponse, [WayPoint])
    case checkTimingFetchPlaceResponse(CafeSearchResponse, [WayPoint], String)
  }

  @Dependency(\.searchWordClient) private var searchWordClient
  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .fetchPlacesAndWaypoints(let searchText):
        if searchText.isEmpty { return .none }
        let timingCheckFlag = state.timingCheckFlag
        return .run { send in
          async let fetchPlaces = try placeAPIClient.fetchPlaces(
            requestValue: PlaceRequestValue(name: searchText, page: 0, size: 10, sort: .ascending)
          )
          async let fetchWaypoints = try placeAPIClient.fetchWaypoints(name: searchText)
          let (places, waypoints) = try await (fetchPlaces, fetchWaypoints)
          /// debounce로 연관검색어목록을 불러오는 것보다, 검색어 submit이 더 빠르게 진행된 경우
          switch timingCheckFlag {
          case true:
            await send(.checkTimingFetchPlaceResponse(places, waypoints, searchText))
          case false:
            await send(.fetchPlacesAndWaypointsResponse(places, waypoints))
          }
        } catch: { error, send in
          debugPrint(error)
        }

      /// debounce로 api가 호출되기전에 유저가 검색어를 done한 경우,
      /// 검색어가 "역"에 해당하는지, 카페목록이 존재하는지 판단
      case .checkTimingFetchPlaceResponse(let places, let waypoints, let searchText):
        state.timingCheckFlag = false
        if waypoints.isNotEmpty && places.cafes.isEmpty {
          guard let waypoint = waypoints.first
          else { return .send(.requestSearchPlace(searchText)) }
          return .send(.requestWaypointSearchPlace(waypoint))
        } else if waypoints.isNotEmpty && places.cafes.isNotEmpty {
          for waypoint in waypoints {
            if waypoint.name == state.searchText ||
                waypoint.name == state.searchText + waypoint.name.suffix(1) {
              return .send(.requestWaypointSearchPlace(waypoint))
            }
          }
        }
        return .send(.requestSearchPlace(searchText))

      case .fetchPlacesAndWaypointsResponse(let places, let waypoints):
        state.places = places.cafes
        state.waypoints = waypoints
        return .none

      case .clearText:
        state.searchText = ""
        state.currentBodyType = .recentSearchListView
        return .none

      case .tappedRecentSearchWord(let recentWord):
        return .send(.requestSearchPlace(recentWord))

      case .binding(\.$searchText):
        if state.searchText.isEmpty {
          state.currentBodyType = .recentSearchListView
        } else {
          state.currentBodyType = .searchResultListView
        }
        state.places = []
        state.waypoints = []
        return EffectTask(value: .fetchPlacesAndWaypoints(state.searchText))
          .debounce(id: CancelID(), for: 0.2, scheduler: DispatchQueue.main)
          .eraseToEffect()

      case .deleteRecentSearchWord(let id):
        return .run { send in
          try await searchWordClient.deleteRecentSearchWord(id: id)
          await send(.fetchRecentSearchWords)
        } catch: { error, send in
          debugPrint(error)
        }

      case .recentSearchWordsResponse(let result):
        switch result {
        case .success(let recentSearchWords):
          state.recentSearchWordList = recentSearchWords
          return .none

        case .failure(let error):
          state.recentSearchWordList = []
          debugPrint(error)
          return .none
        }

      case .fetchRecentSearchWords:
        return .run { send in
          let result = await TaskResult {
            let searchWordResponse = try await searchWordClient.fetchRecentSearchWords()
            let recentSearchWords = searchWordResponse.map {
              RecentSearchWord(
                searchWordId: $0.searchWordId,
                text: $0.text,
                createdAt: $0.createdAt)
            }
            return recentSearchWords
          }
          return await send(.recentSearchWordsResponse(result))
        }

      case .submitText:
        if state.searchText.isEmpty { return .none }
        if state.waypoints.isNotEmpty && state.places.isEmpty {
          guard let waypoint = state.waypoints.first
          else { return .send(.requestSearchPlace(state.searchText)) }
          return .send(.requestWaypointSearchPlace(waypoint))
        } else if state.waypoints.isNotEmpty && state.places.isNotEmpty {
          for waypoint in state.waypoints {
            /// ex) "강남" 또는 "강남역"인 경우에만 -> waypoint 검색
            if waypoint.name == state.searchText ||
                waypoint.name == state.searchText + waypoint.name.suffix(1) {
              return .send(.requestWaypointSearchPlace(waypoint))
            }
          }
          return .send(.requestSearchPlace(state.searchText))
        } else {
          state.timingCheckFlag = true
          return .send(.fetchPlacesAndWaypoints(state.searchText))
        }

      case .dismiss:
        state.cafeList.removeAll()
        state.stationList.removeAll()
        state.recentSearchWordList.removeAll()
        return .none

      case .onAppear:
        state.searchText = ""
        state.currentBodyType = .recentSearchListView
        return .send(.fetchRecentSearchWords)

      default:
        return .none
      }
    }
  }
}
