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
    case hideTabBar
    case showTabBar
  }

  var body: some ReducerProtocolOf<MyPageCoordinator> {
    Reduce<State, Action> { state, action in
      switch action {
      case .routeAction(_, action: .myPage(.pushToLocationServiceTermsView)):
        state.routes.push(.locationServiceTerms(.initialState))
        return .none

      case .routeAction(_, action: .myPage(.pushToPrivacyPolicy)):
        state.routes.push(.privacyPolicy(.initialState))
        return .none

      case .routeAction(_, action: .myPage(.pushToContactView)):
        state.routes.push(.contact(.initialState))
        return .none

      case .routeAction(_, action: .myPage(.pushToEditProfile)):
        state.routes.push(.editProfile(.initialState))
        return .none

      case .routeAction(_, action: .locationServiceTerms(.popView)),
          .routeAction(_, action: .privacyPolicy(.popView)),
          .routeAction(_, action: .contact(.popView)),
          .routeAction(_, action: .editProfile(.popView)):
        state.routes.pop()
        return .none

      case .routeAction(_, action: .editProfile(.hideTabBar)):
        return EffectTask(value: .hideTabBar)

      case .routeAction(_, action: .editProfile(.showTabBar)):
        return EffectTask(value: .showTabBar)

      default:
        return .none
      }
    }
    .forEachRoute {
      MyPageScreen()
    }
  }
}
