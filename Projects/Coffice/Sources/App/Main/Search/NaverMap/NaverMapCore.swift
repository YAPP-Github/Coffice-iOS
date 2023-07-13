//
//  NaverMapCore.swift
//  coffice
//
//  Created by 천수현 on 2023/07/13.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import CoreLocation
import NMapsMap
import SwiftUI

struct NaverMapCore: ReducerProtocol {

  struct State: Equatable {
    // MARK: Selecting Cafe
    var selectedCafe: Cafe? {
      didSet {
        if let unselectedMarker = markers.first(where: { $0.cafe.placeId == oldValue?.placeId }) {
          unselectedMarker.markerType = .init(
            bookmarkType: oldValue?.isBookmarked == true ? .bookmarked : .nonBookmarked,
            selectType: .unselected
          )
        }

        if let selectedMarker = markers.first(where: { $0.cafe.placeId == selectedCafe?.placeId }) {
          selectedMarker.markerType = .init(
            bookmarkType: selectedCafe?.isBookmarked == true ? .bookmarked : .nonBookmarked,
            selectType: .selected
          )
        }
      }
    }

    var markers: [MapMarker] = []
    var currentCameraPosition = CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
    var cafes: [Cafe] = []
    var shouldClearMarkers: Bool = false
    var bottomFloatingButtons = CafeMapCore.BottomFloatingButtonType.allCases
      .map(CafeMapCore.BottomFloatingButton.init)
    var isUpdatingCameraPosition = false
    var isUpdatingMarkers = false
    var shouldUpdateMarkers: Bool {
      return cafes.isNotEmpty && isUpdatingMarkers
    }
    var shouldShowBookmarkCafesOnly = false
    var shouldShowRefreshButtonView: Bool {
      return isMovingCameraPosition.isFalse && cameraUpdateReason != .changedByDeveloper
    }
    var isMovingCameraPosition = false
    var cameraUpdateReason: NaverMapCameraUpdateReason = .changedByDeveloper
  }

  enum Action: Equatable {
    // MARK: View Tap Events
    case refreshButtonTapped
    case bottomFloatingButtonTapped(CafeMapCore.BottomFloatingButtonType)
    case markerTapped(cafe: Cafe)
    case mapViewTapped
    case cardViewBookmarkButtonTapped(cafe: Cafe)

    // MARK: Network Responses
    case cafeListResponse(TaskResult<[Cafe]>)

    case updateCameraToUserPosition
    case updateCafeMarkers(isOpened: Bool, cafeSearchFilters: CafeSearchFilters, hasCommunalTable: Bool)
    case moveCameraToUserPosition

    case removeAllMarkers
    case appendMarker(marker: MapMarker)

    // MARK: Event Completed
    case cameraMovedToUserPosition
    case markersUpdated
    case bookmarkStateUpdated
    case markersCleared
    case updateCameraUpdateReason(NaverMapCameraUpdateReason)
    case cameraPositionMoved(newCameraPosition: CLLocationCoordinate2D)

    case showBookmarkedToast
  }

  // MARK: - Dependencies
  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.locationManager) private var locationManager
  @Dependency(\.bookmarkClient) private var bookmarkClient

  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case .refreshButtonTapped:
        state.cameraUpdateReason = .changedByDeveloper
        return .none

      case .bottomFloatingButtonTapped(let buttonType):
        switch buttonType {
        case .currentLocationButton:
          state.isUpdatingCameraPosition = true
          return .send(.moveCameraToUserPosition)

        case .bookmarkButton:
          if let bookmarkButtonIndex = state.bottomFloatingButtons
            .firstIndex(where: { $0.type == buttonType }) {
            state.isUpdatingMarkers = true
            state.bottomFloatingButtons[bookmarkButtonIndex].isSelected.toggle()
            state.shouldShowBookmarkCafesOnly = state.bottomFloatingButtons[bookmarkButtonIndex].isSelected
          }
          return .none
        }

      case .cardViewBookmarkButtonTapped(let cafe):
        if let selectedCafeIndex = state.cafes
          .firstIndex(where: { $0.placeId == state.selectedCafe?.placeId }) {
          state.cafes[selectedCafeIndex].isBookmarked.toggle()
          state.selectedCafe = state.cafes[selectedCafeIndex]
        }

        return .run { [isBookmarked = state.selectedCafe?.isBookmarked] send in
          if isBookmarked == true {
            try await bookmarkClient.addMyPlace(placeId: cafe.placeId)
            await send(.showBookmarkedToast)
          } else {
            try await bookmarkClient.deleteMyPlace(placeId: cafe.placeId)
          }
        } catch: { error, send in
          debugPrint(error)
        }

      case .moveCameraToUserPosition:
        state.currentCameraPosition = locationManager.fetchCurrentLocation()
        return .none

      case let .updateCafeMarkers(isOpened, cafeSearchFilters, hasCommunalTable):
        state.isUpdatingMarkers = true
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: "",
              userLatitude: 37.498768,
              userLongitude: 127.0277985,
              maximumSearchDistance: 500,
              isOpened: isOpened,
              hasCommunalTable: hasCommunalTable,
              filters: cafeSearchFilters,
              pageSize: 100000,
              pageableKey: nil
            )

            let cafeListData = try await placeAPIClient.searchPlaces(by: cafeRequest)
            return cafeListData.cafes
          }
          await send(.cafeListResponse(result))
        }

      case .cafeListResponse(let result):
        switch result {
        case .success(let cafeList):
          state.cafes = cafeList
          return .none
        case .failure(let error):
          debugPrint(error)
          return .none
        }

      case .markerTapped(let cafe):
        state.selectedCafe = cafe
        return .none

      case .mapViewTapped:
        state.selectedCafe = nil
        return .none

      case .cameraMovedToUserPosition:
        state.isUpdatingCameraPosition = false
        return .none

      case .markersUpdated:
        state.isUpdatingMarkers = false
        return .none

      case .markersCleared:
        state.shouldClearMarkers = false
        return .none

      case .removeAllMarkers:
        state.markers.removeAll()
        state.selectedCafe = nil
        return .none

      case .appendMarker(let marker):
        state.markers.append(marker)
        return .none

      case .updateCameraUpdateReason(let updateReason):
        state.isMovingCameraPosition = true
        state.cameraUpdateReason = updateReason
        return .none

      case .cameraPositionMoved(let newCameraPosition):
        state.currentCameraPosition = newCameraPosition
        state.isMovingCameraPosition = false
        return .none

      default:
        return .none
      }
    }
  }
}
