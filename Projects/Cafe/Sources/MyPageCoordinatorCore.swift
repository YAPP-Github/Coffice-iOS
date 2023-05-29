//
//  MyPageCoordinatorCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/12.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct MyPageCoordinator: ReducerProtocol {
  struct State: Equatable, IndexedRouterState {
    static let initialState: State = .init(
      routes: [.root(.myPage(.init()), embedInNavigationView: false)]
    )

    var routes: [Route<MyPageScreen.State>]
  }

  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: MyPageScreen.Action)
    case updateRoutes([Route<MyPageScreen.State>])
  }

  var body: some ReducerProtocolOf<MyPageCoordinator> {
    Reduce<State, Action> { _, action in
      switch action {
      default:
        return .none
      }
    }
    .forEachRoute {
      MyPageScreen()
    }
  }
}
