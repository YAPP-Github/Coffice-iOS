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
  struct State: Equatable {
    // TODO: Default 위치 값 설정 예정.
    var region: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1, longitude: 1)
    var isCurrentButtonTapped: Bool = false
  }

  enum Action: Equatable {
    case currentLocationButtonTapped
    case requestAuthorization
    case currentLocationResponse(TaskResult<CLLocationCoordinate2D>)
    case fetchCurrentLocation
    case currentButtonToFalse
  }

  @Dependency(\.locationManager) private var locationManager

  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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
    }
  }
}
