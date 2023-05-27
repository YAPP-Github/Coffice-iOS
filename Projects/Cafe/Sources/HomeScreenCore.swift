//
//  HomeScreen.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import TCACoordinators

// MARK: - MainScreenCore

struct HomeScreen: ReducerProtocol {
  enum State: Equatable {
    /// 메인 페이지
    case home(Home.State)
  }

  enum Action: Equatable {
    case home(Home.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: /State.home,
      action: /Action.home
    ) {
      Home()
    }
  }
}
