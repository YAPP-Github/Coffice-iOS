//
//  CafeSearchListCore.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import CoreLocation
import Network
import SwiftUI

struct CafeSearchListCore: Reducer {
  enum ViewType {
    case mapView
    case listView
  }

  struct State: Equatable {
    static var mock: Self {
      .init(cafeFilterInformation: .mock)
    }

    var filterBottomSheetState: CafeFilterBottomSheet.State = .mock
    var filterMenusState: CafeFilterMenus.State = .initialState
    var title: String = ""
    var hasNext: Bool?
    var lastCafeDistance: Double = .zero
    var viewType: ViewType = .mapView
    var cafeList: [Cafe] = []
    var pageSize: Int = 10
    var cafeFilterInformation: CafeFilterInformation = .initialState
    @BindingState var shouldShowToastByBookmark = false
  }

  enum Action: Equatable, BindableAction {
    case updateCafeSearchListState(title: String?, cafeList: [Cafe], hasNext: Bool)
    case updateViewType(ViewType)
    case onAppear
    case scrollAndRequestSearchPlace(Double)
    case searchPlaceResponse(TaskResult<[Cafe]>)
    case cafeFilterMenus(action: CafeFilterMenus.Action)
    case scrollAndLoadData(Cafe)
    case backbuttonTapped
    case dismiss
    case popView
    case titleLabelTapped
    case updateCafeFilter(information: CafeFilterInformation)
    case cafeSearchListCellTapped(cafe: Cafe)
    case focusSelectedCafe(selectedCafe: Cafe)

    // MARK: Search
    case searchPlacesByFilter(SearchPlaceRequestValue)
    case searchPlacesResponseByFilter(TaskResult<CafeSearchResponse>)

    // MARK: Bookmark
    case binding(BindingAction<State>)
    case bookmarkButtonTapped(cafe: Cafe)
    case updateBookmarkedSearchListCell(cafe: Cafe)
    case searchListCellBookmarkUpdated(cafe: Cafe)
    case showBookmarkedToast

    // MARK: DeleateAction
    case delegate(CafeSearchListDelegate)
  }

  // MARK: CafeSearchListDelegate
  enum CafeSearchListDelegate: Equatable {
    case callSearchPlacesByFilter
    case didFinishSearchPlacesByFilter(CafeSearchResponse)
  }
  // MARK: - Dependencies
  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.bookmarkClient) private var bookmarkClient

  var body: some ReducerOf<CafeSearchListCore> {
    BindingReducer()

    Scope(
      state: \.filterMenusState,
      action: /Action.cafeFilterMenus(action:)
    ) {
      CafeFilterMenus()
    }

    Reduce { state, action in
      switch action {
      case .searchPlacesByFilter(let requestValue):
        return .run { send in
          let result = await TaskResult { return try await placeAPIClient.searchPlaces(by: requestValue) }
          await send(.searchPlacesResponseByFilter(result))
        }

      case .searchPlacesResponseByFilter(let result):
        switch result {
        case .success(let response):
          return .merge(
            .send(.delegate(.didFinishSearchPlacesByFilter(response))),
            .send(.updateCafeSearchListState(
              title: nil,
              cafeList: response.cafes,
              hasNext: response.hasNext
            ))
          )
        case .failure(let error):
          debugPrint(error)
          return .none
        }

      case .showBookmarkedToast:
        state.shouldShowToastByBookmark = true
        return .none

      case .updateBookmarkedSearchListCell(let cafe):
        guard let index = state.cafeList.firstIndex(where: { $0.placeId == cafe.placeId })
        else { return .none }
        state.cafeList[index].isBookmarked.toggle()
        return .none

      case .bookmarkButtonTapped(let cafe):
        guard let selectedCafeIndex = state.cafeList.firstIndex(where: { $0.placeId == cafe.placeId })
        else { return .none }

        state.cafeList[selectedCafeIndex].isBookmarked.toggle()
        let selectedCafe = state.cafeList[selectedCafeIndex]

        return .run { send in
          if selectedCafe.isBookmarked {
            try await bookmarkClient.addMyPlace(placeId: cafe.placeId)
            await send(.showBookmarkedToast)
          } else {
            try await bookmarkClient.deleteMyPlace(placeId: cafe.placeId)
          }
          await send(.searchListCellBookmarkUpdated(cafe: cafe))
        } catch: { error, send in
          debugPrint(error)
        }

      case .updateCafeSearchListState(let title, let cafeList, let hasNext):
        if let title { state.title = title }
        state.hasNext = hasNext
        state.cafeList = cafeList
        return .none

      case .cafeSearchListCellTapped(let cafe):
        state.viewType = .mapView
        return .send(.focusSelectedCafe(selectedCafe: cafe))

      case .titleLabelTapped:
        return .none

      case .dismiss:
        return .none

      case .backbuttonTapped:
        state.cafeList = []
        return .send(.dismiss)

      case .updateViewType(let viewType):
        state.viewType = viewType
        return .none

      case .onAppear:
        state.viewType = .mapView
        return .none

      case .scrollAndLoadData(let currentCafe):
        guard let lastCafe = state.cafeList.last else { return .none }
        if state.hasNext ?? false && lastCafe == currentCafe {
          state.lastCafeDistance = lastCafe.distanceFromUser
          return .send(.scrollAndRequestSearchPlace(state.lastCafeDistance))
        }
        return .none

      case .searchPlaceResponse(.success(let cafeList)):
        state.cafeList += cafeList
        return .none

      case .searchPlaceResponse(.failure(let error)):
        debugPrint(error)
        return .none

      case .updateCafeFilter(let information):
        state.cafeFilterInformation = information
        return .none

      case .cafeFilterMenus(.delegate(.updateCafeFilter(let information))):
        state.cafeFilterInformation = information
        return .concatenate(
          .send(.updateCafeFilter(information: information)),
          .send(.delegate(.callSearchPlacesByFilter))
        )

      default:
        return .none
      }
    }
  }
}
