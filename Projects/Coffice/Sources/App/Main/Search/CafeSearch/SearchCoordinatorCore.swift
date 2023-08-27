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

struct SearchCoordinator: Reducer {
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

  var body: some ReducerOf<SearchCoordinator> {
    Reduce<State, Action> { state, action in
      switch action {
      case .routeAction(_, action: .cafeMap(.pushToSearchListForTest)):
        state.routes.push(.cafeSearchList(.init(filterMenusState: .mock)))
        return .none

      case .routeAction(_, action: .cafeSearchList(.popView)):
        state.routes.pop()
        return .none

      case .routeAction(_, action: .cafeMap(.pushToCafeDetailView(let cafeId))):
        state.routes.push(.cafeSearchDetail(.init(cafeId: cafeId)))
        return .none

      case .routeAction(_, action: .cafeSearchDetail(.popView)):
        state.routes.pop()
        return .none

      default:
        return .none
      }
    }
    .forEachRoute {
      SearchScreen()
    }
  }
}
