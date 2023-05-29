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

struct SavedListCoordinator: ReducerProtocol {
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

  var body: some ReducerProtocolOf<SavedListCoordinator> {
    Reduce<State, Action> { _, action in
      switch action {
      default:
        return .none
      }
    }
    .forEachRoute {
      SavedListScreen()
    }
  }
}
