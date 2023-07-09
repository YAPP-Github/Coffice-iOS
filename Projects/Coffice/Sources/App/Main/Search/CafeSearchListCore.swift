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

struct CafeSearchListCore: ReducerProtocol {
  enum ViewType {
    case mapView
    case listView
  }

  struct State: Equatable {
    var filterBottomSheetState: CafeFilterBottomSheet.State = .mock
    var filterMenusState: CafeFilterMenus.State = .mock
    var title: String = ""
    var hasNext: Bool?
    var lastCafeDistance: Double = .zero
    var viewType: ViewType = .mapView
    var cafeList: [Cafe] = []
    var pageSize: Int = 10
    var cafeFilterInformation: CafeFilterInformation = .mock
  }

  enum Action: Equatable {
    case updateViewType(ViewType)
    case onAppear
    case scrollAndRequestSearchPlace(Double)
    case searchPlaceResponse(TaskResult<[Cafe]>)
    case filterMenus(action: CafeFilterMenus.Action)
    case scrollAndLoadData(Cafe)
    case backbuttonTapped
    case dismiss
    case popView
    case titleLabelTapped
    case updateCafeFilter(information: CafeFilterInformation)
    case filterBottomSheetDismissed
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeSearchListCore> {
    Scope(
      state: \.filterMenusState,
      action: /Action.filterMenus(action:)
    ) {
      CafeFilterMenus()
    }

    Reduce { state, action in
      switch action {
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
        return EffectTask(value: .filterMenus(action: .updateCafeFilter(information: information)))

      case .filterBottomSheetDismissed:
        return EffectTask(
          value: .filterMenus(action: .updateCafeFilter(information: state.cafeFilterInformation))
        )

      default:
        return .none
      }
    }
  }
}
