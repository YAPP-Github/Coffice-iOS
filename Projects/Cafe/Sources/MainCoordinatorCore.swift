//
//  HomeCoordinatorCore.swift
//  YappProject
//
//  Created by MinKyeongTae on 2023/05/12.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

/// Main Tab 화면 전환, 이벤트 관리
struct HomeCoordinator: ReducerProtocol {
  struct State: Equatable, IndexedRouterState {
    static let initialState: HomeCoordinator.State = .init(
      routes: [.root(.main(.init()), embedInNavigationView: true)]
    )

    var routes: [Route<HomeScreen.State>]
  }

  enum Action: IndexedRouterAction {
    case routeAction(Int, action: HomeScreen.Action)
    case updateRoutes([Route<HomeScreen.State>])
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      default:
        return .none
      }
    }
    .forEachRoute {
      HomeScreen()
    }
  }
}
