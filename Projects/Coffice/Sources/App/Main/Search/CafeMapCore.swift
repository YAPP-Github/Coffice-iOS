//
//  CafeMapCore.swift
//  Cafe
//
//  Created by sehooon on 2023/06/01.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import CoreLocation
import ComposableArchitecture
import NMapsMap
import SwiftUI

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}

struct CafeMapCore: ReducerProtocol {
  enum FilterOrder: CaseIterable {
    case runningTime
    case outlet
    case spaceSize
    case personnel

    var title: String {
      switch self {
      case .runningTime: return "영업시간"
      case .outlet: return "콘센트"
      case .spaceSize: return "공간크기"
      case .personnel: return "인원"
      }
    }
  }
  enum FloatingButton: CaseIterable {
    case currentLocationButton
    case refreshButton
    case bookmarkButton

    var image: String {
      switch self {
      case .currentLocationButton:
        return "scope"
      case .bookmarkButton:
        return "bookmark"
      case .refreshButton:
        return "arrow.triangle.2.circlepath"
      }
    }
  }

  struct State: Equatable {
    // TODO: Default 위치 값 설정 예정.
    var region: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
    var currentCameraPosition: CLLocationCoordinate2D?
    var cafeList: [CafeMarkerData] = []
    var markerList: [NMFMarker] = []
    var isCurrentButtonTapped: Bool = false
    var isRefreshCompleted: Bool = false
    let filterOrders = FilterOrder.allCases
    let floatingButtons = FloatingButton.allCases
    @BindingState var searchText = ""
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case currentLocationButtonTapped
    case requestLocationAuthorization
    case currentLocationResponse(TaskResult<CLLocationCoordinate2D>)
    case floatingButtonTapped(FloatingButton)
    case fetchCurrentLocation
    case currentButtonToFalse
    case filterOrderMenuClicked(FilterOrder)
    case searchTextDidChanged(text: String)
    case searchTextFieldClearButtonClicked
    case searchTextSubmitted
    case updateCameraPosition(CLLocationCoordinate2D)
    case cafeListResponse(TaskResult<[CafeMarkerData]>)
    case fetchCafeList
    case refreshCompleteToFalse
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.locationManager) private var locationManager

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .clearMarkerList:
        state.markerList.removeAll()
        return .none

      case .fetchCurrentLocation:
        return .run { send in
          await send(
            .currentLocationResponse(
              TaskResult { try await locationManager.fetchCurrentLocation() }
            )
          )
        }

      case let .currentLocationResponse(.success(currentLocation)):
        state.region = currentLocation
        return .none

      case let .currentLocationResponse(.failure(error)):
        debugPrint(error)
        return .none

      case .floatingButtonTapped(let tapped):
        switch tapped {
        case .currentLocationButton:
          return .none
        case .refreshButton:
          return .send(.fetchCafeList)
        case .bookmarkButton:
          return .none
        }

      case .fetchCafeList:
        return .run { send in
          await send(
            .cafeListResponse(
              TaskResult {
                var cafeLocation: [CafeMarkerData] = []
                let cafeListData = try await placeAPIClient.fetchDefaultPlaces(page: 1, size: 20, sort: .ascending)
                  cafeListData.forEach { data in
                  let longitude = data.coordinates.longitude
                  let latitude = data.coordinates.latitude
                  let cafeName = data.name
                  let marker = CafeMarkerData(cafeName: cafeName, latitude: latitude, longitude: longitude)
                  cafeLocation.append(marker)
                }
                return cafeLocation
              }
            )
          )
        }

      case .currentButtonToFalse:
        state.isCurrentButtonTapped = false
        return .none

      case .refreshCompleteToFalse:
        state.isRefreshCompleted = false
        return .none

      case .cafeListResponse(.failure(let error)):
        debugPrint(error)
        return .none

      case .cafeListResponse(.success(let cafeList)):
        state.cafeList = cafeList
        state.isRefreshCompleted = true
        return .none

      case .currentLocationButtonTapped:
        state.isCurrentButtonTapped = true
        return .run { send in
          await send(.fetchCurrentLocation)
        }

      case .requestLocationAuthorization:
        locationManager.requestAuthorization()
        return .run { send in
          await send(.fetchCurrentLocation)
        }

      case .filterOrderMenuClicked:
        // TODO: 필터 메뉴에 따른 이벤트 처리 필요
        return .none

      case .searchTextDidChanged(let text):
        state.searchText = text
        return .none

      case .searchTextFieldClearButtonClicked:
        state.searchText = ""
        return .none

      case .searchTextSubmitted:
        guard state.searchText.trimmingCharacters(in: .whitespaces).isNotEmpty
        else { return .none }
        // TODO: 카페 검색 요청 필요
        return .none

      case .updateCameraPosition(let newPosition):
        state.currentCameraPosition = newPosition
        return .none

      default:
        return .none
      }
    }
  }
}
