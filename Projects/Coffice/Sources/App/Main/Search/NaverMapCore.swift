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
    var isUpdatingBookmarkState = false
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

    // MARK: Network Responses
    case cafeListResponse(TaskResult<[Cafe]>)

    case updateCameraToUserPosition
    case updateCafeMarkers
    case moveCameraToUserPosition

    // MARK: Event Completed
    case cameraMovedToUserPosition
    case markersUpdated
    case bookmarkStateUpdated
    case cleardMarkers
    case updateCameraUpdateReason(NaverMapCameraUpdateReason)
    case cameraPositionMoved(newCameraPosition: CLLocationCoordinate2D)
  }

  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case .refreshButtonTapped:
        state.cameraUpdateReason = .changedByDeveloper
        return .send(.updateCafeMarkers)

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

      default:
        return .none
      }
    }
  }
}
