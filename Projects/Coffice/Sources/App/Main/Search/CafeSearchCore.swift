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
  struct DebouncingCancelId: Hashable {}

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

    // MARK: QuickSearch
    var places: [Cafe] = []
    var waypoints: [WayPoint] = []
    var selectedWaypoints: WayPoint?
    var needToRetryFetchResponse = false
  }

  enum Action: Equatable, BindableAction {
    case dismiss
    case onAppear
    case submitText
    case clearText
    case requestSearchPlace(searchText: String)
    case deleteRecentSearchWord(recentWordId: Int)
    case binding(BindingAction<State>)
    case recentSearchWordCellTapped(recentWord: String)
    case requestSearchPlacesByWaypoint(waypoint: WayPoint)
    case placeCellTapped
    case waypointCellTapped
    case fetchRecentSearchWords
    case fetchPlacesAndWaypoints(searchText: String)
    case recentSearchWordsResponse(TaskResult<[RecentSearchWord]>)
    case fetchPlacesAndWaypointsResponse(CafeSearchResponse, [WayPoint])
    case retryFetchPlacesAndWaypointsResponse(CafeSearchResponse, [WayPoint], searchText: String)
  }

  @Dependency(\.searchWordClient) private var searchWordClient
  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .fetchPlacesAndWaypoints(let searchText):
        if searchText.isEmpty { return .none }
        let needToRetryFetchResponse = state.needToRetryFetchResponse
        return .run { send in
          async let fetchPlaces = try placeAPIClient.fetchPlaces(
            requestValue: PlaceRequestValue(name: searchText, page: 0, size: 10, sort: .ascending)
          )
          async let fetchWaypoints = try placeAPIClient.fetchWaypoints(name: searchText)
          let (places, waypoints) = try await (fetchPlaces, fetchWaypoints)
          switch needToRetryFetchResponse {
          case true:
            await send(.retryFetchPlacesAndWaypointsResponse(places, waypoints, searchText: searchText))
          case false:
            await send(.fetchPlacesAndWaypointsResponse(places, waypoints))
          }
        } catch: { error, send in
          debugPrint(error)
        }

      case .retryFetchPlacesAndWaypointsResponse(let places, let waypoints, let searchText):
        state.needToRetryFetchResponse = false
        if waypoints.isNotEmpty && places.cafes.isEmpty {
          guard let waypoint = waypoints.first
          else { return .send(.requestSearchPlace(searchText: searchText)) }
          return .send(.requestSearchPlacesByWaypoint(waypoint: waypoint))
        } else if waypoints.isNotEmpty && places.cafes.isNotEmpty {
          for waypoint in waypoints {
            let isSearchTextEqualToWaypoint = state.searchText == waypoint.name
            || "\(state.searchText)역" == waypoint.name
            if isSearchTextEqualToWaypoint {
              return .send(.requestSearchPlacesByWaypoint(waypoint: waypoint))
            }
          }
        }
        return .send(.requestSearchPlace(searchText: searchText))

      case .fetchPlacesAndWaypointsResponse(let places, let waypoints):
        state.places = places.cafes
        state.waypoints = waypoints
        return .none

      case .clearText:
        state.searchText = ""
        state.currentBodyType = .recentSearchListView
        return .none

      case .recentSearchWordCellTapped(let recentWord):
        return .send(.requestSearchPlace(searchText: recentWord))

      case .binding(\.$searchText):
        if state.searchText.isEmpty {
          state.currentBodyType = .recentSearchListView
        } else {
          state.currentBodyType = .searchResultListView
        }
        state.places = []
        state.waypoints = []
        return EffectTask(value: .fetchPlacesAndWaypoints(searchText: state.searchText))
          .debounce(id: DebouncingCancelId(), for: 0.2, scheduler: DispatchQueue.main)
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
          else { return .send(.requestSearchPlace(searchText: state.searchText)) }
          return .send(.requestSearchPlacesByWaypoint(waypoint: waypoint))
        } else if state.waypoints.isNotEmpty && state.places.isNotEmpty {
          for waypoint in state.waypoints {
            if state.searchText == waypoint.name ||
                state.searchText + waypoint.name.suffix(1) == waypoint.name {
              return .send(.requestSearchPlacesByWaypoint(waypoint: waypoint))
            }
          }
          return .send(.requestSearchPlace(searchText: state.searchText))
        } else {
          state.needToRetryFetchResponse = true
          return .send(.fetchPlacesAndWaypoints(searchText: state.searchText))
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
