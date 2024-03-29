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

struct CafeSearchCore: Reducer {
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
      return searchText == waypointName || "\(searchText)역" == waypointName
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
    case searchTextDidChange

    // MARK: Network Requests
    case fetchRecentSearchWords
    case fetchWaypoints
    case searchPlacesWithoutFilters
    case searchPlacesWithRequestValue(requestValue: SearchPlaceRequestValue)
    case uploadSearchWord(text: String?)

    // MARK: Network Response
    case fetchWayPointsResponse(waypoints: [WayPoint])
    case recentSearchWordsResponse(TaskResult<[RecentSearchWord]>)
    case searchPlacesWithoutFiltersResponse(cafes: [Cafe])
    case searchPlacesWithRequestValueResponse(cafes: [Cafe])
    case uploadSearchWordResponse(TaskResult<HTTPURLResponse>)

    // MARK: Delegate
    case delegate(CafeSearchCoreDelegate)
  }

  enum CafeSearchCoreDelegate: Equatable {
    case callSearchWithRequestValueByText(searchText: String)
    case searchWithRequestValueByWaypoint(waypoint: WayPoint)
    case focusSelectedPlace(selectedPlace: [Cafe])
    case dismiss
  }

  @Dependency(\.searchWordClient) private var searchWordClient
  @Dependency(\.placeAPIClient) private var placeAPIClient

  // MARK: - Body

  var body: some ReducerOf<Self> {
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
        return .run { send in
          await withTaskCancellation(
            id: DebouncingCancelId(),
            cancelInFlight: true,
            operation: {
              await send(.searchTextDidChange)
            }
          )
        }

      case .searchTextDidChange:
        return .merge(
          .send(.fetchWaypoints),
          .send(.searchPlacesWithoutFilters)
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
        return .merge(
          .send(.delegate(.searchWithRequestValueByWaypoint(waypoint: waypoint))),
          .send(.uploadSearchWord(text: waypoint.name))
        )

      case .placeCellTapped(let place):
        return .merge(
          .send(.uploadSearchWord(text: place.name)),
          .send(.delegate(.focusSelectedPlace(selectedPlace: [place])))
        )

      case .clearTextButtonTapped:
        state.searchText = ""
        state.bodyType = .recentSearchWordsView
        return .none

      case .recentSearchWordCellTapped(let recentWord):
        return .run { send in
          let waypoints = try await placeAPIClient.fetchWaypoints(name: recentWord)
          if let waypoint = waypoints.first {
            await send(.delegate(.searchWithRequestValueByWaypoint(waypoint: waypoint)))
          } else {
            await send(.delegate(.callSearchWithRequestValueByText(searchText: recentWord)))
          }
          await send(.uploadSearchWord(text: recentWord))
        }

      case .deleteRecentSearchWordButtonTapped(let id):
        return .run { send in
          try await searchWordClient.deleteRecentSearchWord(id: id)
          await send(.fetchRecentSearchWords)
        } catch: { error, send in
          debugPrint(error)
        }

      case .submitText:
        guard state.searchText.isNotEmpty else { return .none }
        return .run { [searchText = state.searchText] send in
          let waypoints = try await placeAPIClient.fetchWaypoints(name: searchText)
          if let waypoint = waypoints.first {
            await send(.delegate(.searchWithRequestValueByWaypoint(waypoint: waypoint)))
          } else {
            await send(.delegate(.callSearchWithRequestValueByText(searchText: searchText)))
          }
          await send(.uploadSearchWord(text: searchText))
        }

        // MARK: - Network Requests
      case .uploadSearchWord(let text):
        return .run { send in
          let result = await TaskResult {
            try await searchWordClient.uploadRecentSearchWord(text: text)
          }
          await send(.uploadSearchWordResponse(result))
        }

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
          await send(.searchPlacesWithRequestValueResponse(cafes: result.cafes))
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
        guard cafes.isNotEmpty else {
          state.bodyType = .searchResultEmptyView
          return .none
        }
        return .send(.delegate(.focusSelectedPlace(selectedPlace: cafes)))

      case .uploadSearchWordResponse(let result):
        switch result {
        case .failure(let error):
          debugPrint(error)
          return .none
        default:
          return .none
        }

      default:
        return .none
      }
    }
  }
}
