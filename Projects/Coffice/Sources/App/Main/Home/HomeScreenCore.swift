//
//  HomeScreen.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import TCACoordinators

struct HomeScreen: Reducer {
  enum State: Equatable {
    /// 메인 페이지
    case home(Home.State)
  }

  enum Action: Equatable {
    case home(Home.Action)
  }

  var body: some ReducerOf<HomeScreen> {
    Scope(
      state: /State.home,
      action: /Action.home
    ) {
      Home()
    }
  }
}
