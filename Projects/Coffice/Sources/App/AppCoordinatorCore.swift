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

struct AppCoordinator: Reducer {
  struct State: Equatable, IndexedRouterState {
    static let mock: State = .init(
      routes: [.root(.login(.initialState), embedInNavigationView: false)]
    )

    init(routes: [Route<AppScreen.State>]) {
      self.routes = routes
    }

    init() {
      if UserDefaults.standard.bool(forKey: "alreadyLaunched").isFalse {
        KeychainManager.shared.deleteUserToken()
      }

      let isAlreadyLoggedIn = CoreNetwork.shared.token != nil

      if isAlreadyLoggedIn {
        routes = [.root(.main(.initialState), embedInNavigationView: false)]
      } else {
        routes = [
            .root(.main(.initialState), embedInNavigationView: false),
            .cover(.login(.init(isOnboarding: false)))
        ]
      }
    }

    var routes: [Route<AppScreen.State>]
  }

  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: AppScreen.Action)
    case updateRoutes([Route<AppScreen.State>])
    case dismissAllRoutes
    case presentLoginView
  }

  var body: some ReducerOf<AppCoordinator> {
    Reduce { state, action in
      switch action {
      case .routeAction(_, action: .login(.routeAction(_, action: .main(.loginCompleted)))):
        state.routes.dismissAll()
        UserDefaults.standard.setValue(true, forKey: "alreadyLaunched")
        UserDefaults.standard.setValue(true, forKey: UserDefaultsKeyString.onBoardingWithCafeMapView.forKey)
        return .send(.routeAction(0, action: .main(.loginCompleted)))

      case .routeAction(_, action: .main(.myPage(.routeAction(_, action: .myPage(.delegate(.logoutCompleted)))))),
          .routeAction(_, action: .main(.myPage(.routeAction(_, action: .myPage(.delegate(.memberLeaveCompleted)))))):
        KeychainManager.shared.deleteUserToken()
        UserDefaults.standard.setValue(false, forKey: "alreadyLaunched")
        UserDefaults.standard.setValue(false, forKey: UserDefaultsKeyString.onBoardingWithCafeMapView.forKey)
        return .merge(
          .send(.dismissAllRoutes),
          .run { send in
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await send(.presentLoginView)
          }
        )

      case .routeAction(_, action: .main(.myPage(.delegate(.pushLogin)))):
        return .send(.presentLoginView)

      case .routeAction(_, action: .login(.routeAction(_, action: .main(.dismissButtonTapped)))):
        state.routes.dismiss()
        return .none

      case .dismissAllRoutes:
        state.routes.dismissAll()
        return .none

      case .presentLoginView:
        state.routes.presentCover(.login(.init(isOnboarding: false)))
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
