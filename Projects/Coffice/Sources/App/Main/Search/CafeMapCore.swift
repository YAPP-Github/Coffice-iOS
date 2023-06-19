//
//  CafeMapCore.swift
//  Cafe
//
//  Created by sehooon on 2023/06/01.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

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

  struct State: Equatable {
    // TODO: Default 위치 값 설정 예정.
    var region: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1, longitude: 1)
    var isCurrentButtonTapped: Bool = false
    let filterOrders = FilterOrder.allCases
    @BindingState var searchText = ""
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case currentLocationButtonTapped
    case requestAuthorization
    case currentLocationResponse(TaskResult<CLLocationCoordinate2D>)
    case fetchCurrentLocation
    case currentButtonToFalse
    case filterOrderMenuClicked(FilterOrder)
    case searchTextFieldTyped(text: String)
    case searchTextFieldClearButtonClicked
    case searchTextSubmitted
  }

  @Dependency(\.locationManager) private var locationManager

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .currentButtonToFalse:
        state.isCurrentButtonTapped = false
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

      case .currentLocationButtonTapped:
        state.isCurrentButtonTapped = true
        return .run { send in
          await send(.fetchCurrentLocation)
        }

      case .requestAuthorization:
        locationManager.requestAuthorization()
        return .run { send in
          await send(.fetchCurrentLocation)
        }

      case .filterOrderMenuClicked:
        // TODO: 필터 메뉴에 따른 이벤트 처리 필요
        return .none

      case .searchTextFieldTyped(let text):
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

      default:
        return .none
      }
    }
  }
}
