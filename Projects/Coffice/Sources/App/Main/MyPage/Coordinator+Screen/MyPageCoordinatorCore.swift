//
//  MyPageCoordinatorCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/12.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct MyPageCoordinator: Reducer {
  struct State: Equatable, IndexedRouterState {
    static let initialState: State = .init(
      routes: [.root(.myPage(.init()), embedInNavigationView: false)]
    )

    var routes: [Route<MyPageScreen.State>]
  }

  enum Action: IndexedRouterAction, Equatable, BindableAction {
    case routeAction(Int, action: MyPageScreen.Action)
    case updateRoutes([Route<MyPageScreen.State>])
    case binding(BindingAction<State>)
    case delegate(MyPageCoordinatorDelegate)
  }

  enum MyPageCoordinatorDelegate {
    case pushLogin
  }

  var body: some ReducerOf<MyPageCoordinator> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .routeAction(_, action: .myPage(.menuButtonTapped(let menuItem))):
        switch menuItem.menuType {
        case .privacyPolicy:
          state.routes.push(.privacyPolicy(.initialState))
        case .appServiceTerms:
          state.routes.push(.appServiceTerms(.initialState))
        case .locationServiceTerms:
          state.routes.push(.locationServiceTerms(.initialState))
        default:
          break
        }
        return .none

      case .routeAction(_, action: .myPage(.delegate(.editProfileButtonTapped(let nickname, let loginType)))):
        if loginType == .anonymous {
          return .send(.delegate(.pushLogin))
        } else {
          state.routes.push(.editProfile(.init(nickname: nickname)))
        }
        return .none

      case .routeAction(_, action: .locationServiceTerms(.popView)),
          .routeAction(_, action: .appServiceTerms(.popView)),
          .routeAction(_, action: .privacyPolicy(.popView)),
          .routeAction(_, action: .editProfile(.popView)):
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
