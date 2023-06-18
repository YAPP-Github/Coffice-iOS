//
//  SearchCoordinatorCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct SearchCoordinator: ReducerProtocol {
  struct State: Equatable, IndexedRouterState {
    static let initialState: State = .init(
      routes: [.root(.cafeMap(.init()), embedInNavigationView: false)]
    )

    var routes: [Route<SearchScreen.State>]
  }

  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: SearchScreen.Action)
    case updateRoutes([Route<SearchScreen.State>])
  }

  var body: some ReducerProtocolOf<SearchCoordinator> {
    Reduce<State, Action> { _, action in
      switch action {
      default:
        return .none
      }
    }
    .forEachRoute {
      SearchScreen()
    }
  }
}
