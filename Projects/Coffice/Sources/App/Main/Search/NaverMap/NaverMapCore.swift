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
    var shouldShowRefreshButtonView: Bool {
      return isMovingCameraPosition.isFalse && recentCameraUpdateReason != .changedByDeveloper
    }

    // MARK: Selecting Cafe
    fileprivate(set) var selectedCafe: Cafe? {
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

    fileprivate(set) var markers: [MapMarker] = []
    fileprivate(set) var currentCameraPosition = CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
    fileprivate(set) var cafes: [Cafe] = []
    fileprivate(set) var shouldClearMarkers: Bool = false
    fileprivate(set) var bottomFloatingButtons = CafeMapCore.BottomFloatingButtonType.allCases
      .map(CafeMapCore.BottomFloatingButton.init)
    fileprivate(set) var isUpdatingCameraPosition = false
    fileprivate(set) var shouldUpdateMarkers = false
    fileprivate(set) var isUpdatingMarkers = false
    fileprivate(set) var shouldShowBookmarkCafesOnly = false
    fileprivate(set) var shouldShowOpenTime = false

    fileprivate(set) var isMovingCameraPosition = false
    fileprivate(set) var recentCameraUpdateReason: NaverMapCameraUpdateReason = .changedByDeveloper

    mutating func removeAllMarkers() {
      selectedCafe = nil
      recentCameraUpdateReason = .changedByDeveloper
      markers.forEach {
        $0.touchHandler = nil
        $0.mapView = nil
      }
      markers.removeAll()
    }

    mutating func toggleOpenTime() {
      if shouldShowOpenTime {
        markers.forEach {
          $0.subCaptionText = $0.cafe.openingInformation?.quickFormattedString ?? "정보없음"
          $0.subCaptionColor = CofficeAsset.Colors.secondary1.color
        }
      } else {
        markers.forEach {
          $0.subCaptionText = ""
        }
      }
    }
  }

  enum Action: Equatable {
    // MARK: View Tap Events
    case refreshButtonTapped
    case bottomFloatingButtonTapped(CafeMapCore.BottomFloatingButtonType)
    case markerTapped(cafe: Cafe)
    case mapViewTapped
    case cardViewBookmarkButtonTapped(cafe: Cafe)
    case searchListCellBookmarkButtonTapped(cafe: Cafe)

    // MARK: Move Camera
    case moveCameraToUserPosition
    case moveCameraTo(position: CLLocationCoordinate2D)

    // MARK: Network Requests
    case searchPlacesWithRequestValue(requestValue: SearchPlaceRequestValue)

    // MARK: Network Responses
    case cafeListResponse(TaskResult<[Cafe]>)

    // MARK: On/Off Flag After Update UI Completed
    case cameraMovedToUserPosition
    case markersUpdated
    case markersCleared
    case cameraPositionUpdated(toPosition: CLLocationCoordinate2D, byReason: NaverMapCameraUpdateReason)
    case cameraPositionMoved(newCameraPosition: CLLocationCoordinate2D)

    // MARK: Functions
    case updatePinnedCafes(cafes: [Cafe])
    case updateSelectedCafeState
    case removeAllMarkers
    case appendMarkers(markers: [MapMarker])
    case selectCafe(cafe: Cafe)
    case unselectCafe
    case addCafes(cafes: [Cafe])

    // MARK: ETC
    case delegate(NaverMapDelegate)
    case showBookmarkedToast
    case searchListCellBookmarkUpdated(cafe: Cafe)
  }

  enum NaverMapDelegate: Equatable {
    case callSearchPlacesWithRequestValue
    case callUpdateBookmarkSearchListCell(cafe: Cafe)
  }

  // MARK: - Dependencies
  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.locationManager) private var locationManager
  @Dependency(\.bookmarkClient) private var bookmarkClient

  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {

        // MARK: - View Tap Events
      case .refreshButtonTapped:
        state.recentCameraUpdateReason = .changedByDeveloper
        for index in 0..<state.bottomFloatingButtons.count {
          state.bottomFloatingButtons[index].isSelected = false
        }
        state.shouldShowBookmarkCafesOnly = false
        state.shouldShowOpenTime = false
        return .run { send in
          await send(.removeAllMarkers)
          await send(.delegate(.callSearchPlacesWithRequestValue))
        }

      case .bottomFloatingButtonTapped(let buttonType):
        switch buttonType {
        case .openTimeButton:
          if let clockButtonIndex = state.bottomFloatingButtons
            .firstIndex(where: { $0.type == buttonType }) {
            state.shouldUpdateMarkers = true
            state.bottomFloatingButtons[clockButtonIndex].isSelected.toggle()
            state.shouldShowOpenTime = state.bottomFloatingButtons[clockButtonIndex].isSelected
            state.toggleOpenTime()
          }
          return .none
        case .currentLocationButton:
          state.isUpdatingCameraPosition = true
          return .send(.moveCameraToUserPosition)

        case .bookmarkButton:
          if let bookmarkButtonIndex = state.bottomFloatingButtons
            .firstIndex(where: { $0.type == buttonType }) {
            state.removeAllMarkers()
            state.shouldUpdateMarkers = true
            state.bottomFloatingButtons[bookmarkButtonIndex].isSelected.toggle()
            state.shouldShowBookmarkCafesOnly = state.bottomFloatingButtons[bookmarkButtonIndex].isSelected
          }
          return .none
        }

      case .searchListCellBookmarkUpdated(let cafe):
        guard let selectedCafeIndex = state.cafes.firstIndex(where: { $0.placeId == cafe.placeId })
        else { return .none }
        state.cafes[selectedCafeIndex].isBookmarked.toggle()
        let selectedCafe = state.cafes[selectedCafeIndex]

        return .concatenate(
          EffectTask(value: .updatePinnedCafes(cafes: state.cafes)),
          .merge(
            EffectTask(value: .selectCafe(cafe: selectedCafe)),
            EffectTask(value: .moveCameraTo(position: CLLocationCoordinate2DMake(cafe.latitude, cafe.longitude)))
          )
        )

      case .cardViewBookmarkButtonTapped(let cafe):
        guard let selectedCafeIndex = state.cafes.firstIndex(where: { $0.placeId == cafe.placeId })
        else { return .none }
        state.cafes[selectedCafeIndex].isBookmarked.toggle()
        let selectedCafe = state.cafes[selectedCafeIndex]

        return .run { [cafes = state.cafes] send in
          if selectedCafe.isBookmarked {
            try await bookmarkClient.addMyPlace(placeId: selectedCafe.placeId)
            await send(.showBookmarkedToast)
          } else {
            try await bookmarkClient.deleteMyPlace(placeId: selectedCafe.placeId)
          }
          await send(.delegate(.callUpdateBookmarkSearchListCell(cafe: selectedCafe)))
          await send(.updatePinnedCafes(cafes: cafes))
          await send(.selectCafe(cafe: selectedCafe))
        } catch: { error, send in
          debugPrint(error)
        }

      case .markerTapped(let cafe):
        state.selectedCafe = cafe
        return .none

      case .mapViewTapped:
        state.selectedCafe = nil
        return .none

        // MARK: - Move Camera

      case .moveCameraToUserPosition:
        state.currentCameraPosition = locationManager.fetchCurrentLocation()
        return .none

      case .moveCameraTo(let position):
        state.currentCameraPosition = position
        state.isUpdatingCameraPosition = true
        return .none

        // MARK: - Network Requests

      case .searchPlacesWithRequestValue(let requestValue):
        return .run { send in
          let cafeResponse = try await placeAPIClient.searchPlaces(by: requestValue)
          await send(.updatePinnedCafes(cafes: cafeResponse.cafes))
        }

        // MARK: - Network Responses

      case .cafeListResponse(let result):
        switch result {
        case .success(let cafeList):
          state.cafes = cafeList
          return .none
        case .failure(let error):
          debugPrint(error)
          return .none
        }

        // MARK: - On/Off Flag After Update UI Completed

      case .cameraMovedToUserPosition:
        state.isUpdatingCameraPosition = false
        return .none

      case .markersUpdated:
        state.shouldUpdateMarkers = false
        NaverMapViewProgressChecker.shared.isUpdatingMarkers = false
        return .none

      case .markersCleared:
        state.shouldClearMarkers = false
        return .none

      case .cameraPositionUpdated(let updatedPosition, let updateReason):
        state.currentCameraPosition = updatedPosition
        state.recentCameraUpdateReason = updateReason
        state.isMovingCameraPosition = false
        return .none

        // MARK: - Functions (외부에서 호출 가능)

      case .updatePinnedCafes(let cafes):
        state.removeAllMarkers()
        state.cafes = cafes
        state.shouldUpdateMarkers = true
        return .none

      case .removeAllMarkers:
        state.removeAllMarkers()
        return .none

      case .appendMarkers(let markers):
        state.markers.append(contentsOf: markers)
        return .none

      case .selectCafe(let cafe):
        state.selectedCafe = cafe
        return .none

      case .unselectCafe:
        state.selectedCafe = nil
        return .none

      case .addCafes(let cafes):
        state.cafes.append(contentsOf: cafes)
        state.shouldUpdateMarkers = true
        return .none

      case .updateSelectedCafeState:
        return .run { [selectedCafe = state.selectedCafe] send in
          if let selectedCafe {
            let selectedCafe = try await placeAPIClient.fetchPlace(placeId: selectedCafe.placeId)
            await send(.selectCafe(cafe: selectedCafe))
          }
        }

      default:
        return .none
      }
    }
  }
}
