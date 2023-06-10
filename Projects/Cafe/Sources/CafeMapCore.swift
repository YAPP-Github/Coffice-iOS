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
  }

  enum Action: Equatable {
    case currentLocationButtonTapped
    case requestAuthorization
    case currentLocationResponse(CLLocationCoordinate2D)
  }

  @Dependency(\.locationManager) private var locationManager

  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case let .currentLocationResponse(currentLocation):
      state.region = currentLocation
      return .none
    case .currentLocationButtonTapped:
      // TODO: Logger제작 시, Logging 예정.
      return .run { send in
        do {
          let region = try await locationManager.fetchCurrentLocation()
          await send(.currentLocationResponse(region))
        } catch {
          debugPrint(error)
        }
      }
    case .requestAuthorization:
      locationManager.requestAuthorization()
      return .run { send in
        await send(.currentLocationButtonTapped)
      }
    }
  }
}
