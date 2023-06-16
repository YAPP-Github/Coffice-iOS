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
    Reduce<State, Action> { state, action in
      switch action {
      case .routeAction(_, action: .myPage(.pushToServiceTermsView)):
        state.routes.push(.serviceTerms(.initialState))
        return .none

      case .routeAction(_, action: .myPage(.pushToPrivacyPolicy)):
        state.routes.push(.privacyPolicy(.initialState))
        return .none

      case .routeAction(_, action: .myPage(.pushToOpenSourcesView)):
        state.routes.push(.openSources(.initialState))
        return .none

      case .routeAction(_, action: .myPage(.pushToDevTestView)):
        state.routes.push(.devTest(.initialState))
        return .none

      case .routeAction(_, action: .serviceTerms(.popView)),
          .routeAction(_, action: .privacyPolicy(.popView)),
          .routeAction(_, action: .openSources(.popView)),
          .routeAction(_, action: .devTest(.popView)):
        state.routes.pop()
        return .none

      default:
        return .none
      }
    }
    .forEachRoute {
      MyPageScreen()
    }
  }
}
