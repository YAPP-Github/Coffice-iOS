//
//  AppCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import Foundation
import TCACoordinators

struct AppCoordinator: ReducerProtocol {
  struct State: Equatable, IndexedRouterState {
    static let initialState: State = .init(
      routes: [.root(.main(.initialState), embedInNavigationView: true)]
    )
    
    var routes: [Route<AppScreen.State>]
    var mainState: MainCoordinator.State = .initialState
    var isLoggedIn = false
  }

  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: AppScreen.Action)
    case updateRoutes([Route<AppScreen.State>])
    case login
    case useAppAsNonMember
    case main(MainCoordinator.Action)
  }

  var body: some ReducerProtocolOf<AppCoordinator> {
    Reduce { state, action in
      switch action {
      case .login:
        return .none

      case .useAppAsNonMember:
        return .none
        
      case .main(let action):
        switch action {
        default:
          return .none
        }

      default:
        return .none
      }
    }
    .forEachRoute {
      AppScreen()
    }
  }
}
