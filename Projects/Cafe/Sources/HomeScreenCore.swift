//
//  HomeScreen.swift
//  YappProject
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import TCACoordinators

// MARK: - MainScreenCore

struct HomeScreen: ReducerProtocol {
  enum State: Equatable {
    /// 메인 페이지
    case main(Home.State)
  }

  enum Action: Equatable {
    case main(Home.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: /State.main,
      action: /Action.main
    ) {
      Home()
    }
  }
}
