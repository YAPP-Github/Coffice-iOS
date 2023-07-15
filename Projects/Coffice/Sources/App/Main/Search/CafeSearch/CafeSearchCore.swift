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
    case recentSearchWordsView
    case searchResultEmptyView
    case searchResultListView
  }

  struct State: Equatable {
    @BindingState var searchText = ""
    var recentSearchWordList: [RecentSearchWord] = []
    var previousViewType: CafeMapCore.ViewType = .mainMapView
    var bodyType: CafeSearchViewBodyType = .searchResultListView
    var cafes: [Cafe] = []
    var waypoints: [WayPoint] = []
    var selectedWaypoint: WayPoint?

    fileprivate func isSearchTextEqualToWaypoint(waypointName: String) -> Bool {
      return (searchText == waypointName || "\(searchText)역" == waypointName) ? true : false
    }
  }

  enum Action: Equatable, BindableAction {
    // MARK: Binding
    case binding(BindingAction<State>)

    // MARK: View Life Cycle
    case onAppear

    // MARK: View Tap Events
    case submitText
    case clearTextButtonTapped
    case deleteRecentSearchWordButtonTapped(recentWordId: Int)
    case recentSearchWordCellTapped(recentWord: String)
    case placeCellTapped(place: Cafe)
    case waypointCellTapped(waypoint: WayPoint)

    // MARK: Network Requests
    case fetchRecentSearchWords
    case fetchWaypoints
    case searchPlacesWithoutFilters
    case searchPlacesWithRequestValue(requestValue: SearchPlaceRequestValue)

    // MARK: Network Response
    case fetchWayPointsResponse(waypoints: [WayPoint])
    case recentSearchWordsResponse(TaskResult<[RecentSearchWord]>)
    case searchPlacesWithoutFiltersResponse(cafes: [Cafe])
    case searchPlacesWithRequestValueResponse(cafes: [Cafe])

    // MARK: Delegate
    case delegate(CafeSearchCoreDelegate)
  }

  enum CafeSearchCoreDelegate: Equatable {
    case requestToCallSearchWithRequestValue(searchText: String)
    case focusSelectedPlace(selectedPlace: Cafe)
    case dismiss
  }

  @Dependency(\.searchWordClient) private var searchWordClient
  @Dependency(\.placeAPIClient) private var placeAPIClient

  // MARK: - Body

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {

        // MARK: - Binding

      case .binding(\.$searchText):
        if state.searchText.isEmpty {
          state.bodyType = .recentSearchWordsView
        } else {
          state.bodyType = .searchResultListView
        }
        return .merge(
          EffectTask(value: .fetchWaypoints),
          EffectTask(value: .searchPlacesWithoutFilters)
        )
        .debounce(
          id: DebouncingCancelId(),
          for: 0.5,
          scheduler: DispatchQueue.main
        )

        // MARK: - View Life Cycle

      case .delegate(.dismiss):
        state.recentSearchWordList.removeAll()
        return .none

      case .onAppear:
        state.searchText = ""
        state.bodyType = .recentSearchWordsView
        return .send(.fetchRecentSearchWords)

        // MARK: - View Tap Events

      case .waypointCellTapped(let waypoint):
        return EffectTask(value: .searchPlacesWithoutFilters)

      case .placeCellTapped(let place):
        return EffectTask(value: .delegate(.focusSelectedPlace(selectedPlace: place)))

      case .clearTextButtonTapped:
        state.searchText = ""
        state.bodyType = .recentSearchWordsView
        return .none

      case .recentSearchWordCellTapped(let recentWord):
        return EffectTask(value: .delegate(.requestToCallSearchWithRequestValue(searchText: recentWord)))

      case .deleteRecentSearchWordButtonTapped(let id):
        return .run { send in
          try await searchWordClient.deleteRecentSearchWord(id: id)
          await send(.fetchRecentSearchWords)
        } catch: { error, send in
          debugPrint(error)
        }

      case .submitText:
        guard state.searchText.isNotEmpty else { return .none }

        switch (state.cafes.isEmpty, state.waypoints.isEmpty) {
        case (true, false):
          guard let waypoint = state.waypoints.first
          else { return EffectTask(value: .searchPlacesWithoutFilters) }
          return EffectTask(value: .delegate(.requestToCallSearchWithRequestValue(searchText: waypoint.name)))

        case (false, false):
          let waypointsToSearch = state.waypoints.filter {
            state.isSearchTextEqualToWaypoint(waypointName: $0.name)
          }

          return .run { [searchText = state.searchText] send in
            for waypoint in waypointsToSearch {
              // FIXME: async하게 못보내나?
              await send(.delegate(.requestToCallSearchWithRequestValue(searchText: waypoint.name)))
            }
            await send(.delegate(.requestToCallSearchWithRequestValue(searchText: searchText)))
          }

        case (_, true):
          return EffectTask(value: .delegate(.requestToCallSearchWithRequestValue(searchText: state.searchText)))
        }

        // MARK: - Network Requests

      case .fetchRecentSearchWords:
        return .run { send in
          let result = await TaskResult {
            let searchWordResponse = try await searchWordClient.fetchRecentSearchWords()
            let recentSearchWords = searchWordResponse.map {
              RecentSearchWord(
                searchWordId: $0.searchWordId,
                text: $0.text,
                createdAt: $0.createdAt
              )
            }
            return recentSearchWords
          }
          return await send(.recentSearchWordsResponse(result))
        }

      case .fetchWaypoints:
        return .run { [searchText = state.searchText] send in
          let waypoints = try await placeAPIClient.fetchWaypoints(name: searchText)
          await send(.fetchWayPointsResponse(waypoints: waypoints))
        }

      case .searchPlacesWithoutFilters:
        return .run { [searchText = state.searchText] send in
          let cafeSearchResponse = try await placeAPIClient.searchPlaces(by: searchText)
          await send(.searchPlacesWithoutFiltersResponse(cafes: cafeSearchResponse.cafes))
        }

      case .searchPlacesWithRequestValue(let requestValue):
        return .run { send in
          let result = try await placeAPIClient.searchPlaces(by: requestValue)
        }

        // MARK: - Network Responses

      case .recentSearchWordsResponse(let result):
        switch result {
        case .success(let recentSearchWords):
          state.recentSearchWordList = recentSearchWords

        case .failure(let error):
          state.recentSearchWordList = []
          debugPrint(error)
        }
        return .none

      case .fetchWayPointsResponse(let waypoints):
        state.waypoints = waypoints
        return .none

      case .searchPlacesWithoutFiltersResponse(let cafes):
        state.cafes = cafes
        return .none

      case .searchPlacesWithRequestValueResponse(let cafes):
        guard let cafe = cafes.first
        else { return .none }
        return EffectTask(value: .delegate(.focusSelectedPlace(selectedPlace: cafe)))

      default:
        return .none
      }
    }
  }
}
