//
//  MainCoordinatorCore.swift
//  YappProject
//
//  Created by MinKyeongTae on 2023/05/12.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

/// Main Tab 화면 전환, 이벤트 관리
struct MainCoordinator: ReducerProtocol {
  struct State: Equatable, IndexedRouterState {
    static let initialState: MainCoordinator.State = .init(
      routes: [.root(.main(.init()), embedInNavigationView: true)]
    )

    var routes: [Route<MainScreen.State>]
  }

  enum Action: IndexedRouterAction {
    case routeAction(Int, action: MainScreen.Action)
    case updateRoutes([Route<MainScreen.State>])
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .routeAction(_, .main(.secondActive(true))
      ):
        state.routes.push(.second(.init()))

      case .routeAction(_, .second(.thirdActive(true))
      ):
        state.routes.push(.third(.init()))

      case .routeAction(_, .main(.modalPresented(true))
      ):
        state.routes.presentCover(.modal(.init()))

      case .routeAction(_, .modal(.dismiss)):
        state.routes.dismiss()

      case .routeAction(_, .third(.popToRootView)):
        state.routes.popToCurrentNavigationRoot()

      default:
        return .none
      }

      return .none
    }
    .forEachRoute {
      MainScreen()
    }
  }
}
