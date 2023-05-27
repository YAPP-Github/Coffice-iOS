//
//  MyPageCoordinatorCore.swift
//  YappProject
//
//  Created by MinKyeongTae on 2023/05/12.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

/// Main Tab 화면 전환, 이벤트 관리
struct MyPageCoordinator: ReducerProtocol {
  struct State: Equatable, IndexedRouterState {
    static let initialState: State = .init(
      routes: [.root(.myPage(.init()), embedInNavigationView: true)]
    )

    var routes: [Route<MyPageScreen.State>]
  }

  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: MyPageScreen.Action)
    case updateRoutes([Route<MyPageScreen.State>])
  }

  var body: some ReducerProtocol<State, Action> {
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
