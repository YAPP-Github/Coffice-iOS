//
//  LoginCoordinatorCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct LoginCoordinator: ReducerProtocol {
  struct State: Equatable, IndexedRouterState {
    static let initialState: State = .init(
      routes: [.root(.main(.initialState), embedInNavigationView: false)]
    )

    var routes: [Route<LoginScreen.State>]
  }

  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: LoginScreen.Action)
    case updateRoutes([Route<LoginScreen.State>])
  }

  var body: some ReducerProtocolOf<LoginCoordinator> {
    Reduce<State, Action> { _, action in
      switch action {
      default:
        return .none
      }
    }
    .forEachRoute {
      LoginScreen()
    }
  }
}
