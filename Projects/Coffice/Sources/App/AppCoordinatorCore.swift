//
//  AppCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Network
import TCACoordinators

struct AppCoordinator: ReducerProtocol {
  struct State: Equatable, IndexedRouterState {
    static let initialState: State = .init(
      routes: [.root(.login(.initialState), embedInNavigationView: false)]
    )

    init(routes: [Route<AppScreen.State>]) {
      self.routes = routes
    }

    init() {
      if UserDefaults.standard.bool(forKey: "alreadyLaunched").isFalse {
        KeychainManager.shared.deleteUserToken()
        UserDefaults.standard.setValue(true, forKey: "alreadyLaunched")
      }

      let isAlreadyLoginned = CoreNetwork.shared.token != nil

      if isAlreadyLoginned {
        routes = [.root(.main(.initialState), embedInNavigationView: false)]
      } else {
        routes = [.root(.login(.initialState), embedInNavigationView: false)]
      }
    }

    var routes: [Route<AppScreen.State>]
  }

  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: AppScreen.Action)
    case updateRoutes([Route<AppScreen.State>])
  }

  var body: some ReducerProtocolOf<AppCoordinator> {
    Reduce { state, action in
      switch action {
      case .routeAction(_, action: .login(.routeAction(_, action: .main(.loginCompleted)))):
        state.routes.dismissAll()
        state.routes.presentCover(.main(.initialState))
        return .none

      default:
        return .none
      }
    }
    .forEachRoute {
      AppScreen()
    }
  }
}
