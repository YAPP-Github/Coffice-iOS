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
  }

  enum Action: Equatable {
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
    case searchPlacesByFilter
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeSearchListCore> {
    Scope(
      state: \.filterMenusState,
      action: /Action.cafeFilterMenus(action:)
    ) {
      CafeFilterMenus()
    }

    Reduce { state, action in
      switch action {
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
          EffectTask(value: .updateCafeFilter(information: information)),
          EffectTask(value: .searchPlacesByFilter)
        )

      default:
        return .none
      }
    }
  }
}
