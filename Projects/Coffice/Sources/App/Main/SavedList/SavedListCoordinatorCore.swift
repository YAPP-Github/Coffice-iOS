//
//  SavedListCoordinatorCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct SavedListCoordinator: Reducer {
  struct State: Equatable, IndexedRouterState {
    static let initialState: State = .init(
      routes: [.root(.savedList(.init()), embedInNavigationView: false)]
    )

    var routes: [Route<SavedListScreen.State>]
  }

  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: SavedListScreen.Action)
    case updateRoutes([Route<SavedListScreen.State>])
  }

  var body: some ReducerOf<SavedListCoordinator> {
    Reduce<State, Action> { state, action in
      switch action {
      case .routeAction(_, action: .savedList(.pushCafeDetail(let cafeId))):
        state.routes.push(.cafeSearchDetail(.init(cafeId: cafeId)))
        return .none

      case .routeAction(_, action: .cafeSearchDetail(.popView)):
        state.routes.pop()
        return .none

      default:
        return .none
      }
    }
    .forEachRoute {
      SavedListScreen()
    }
  }
}
