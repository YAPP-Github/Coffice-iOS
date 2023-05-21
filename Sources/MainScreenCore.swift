//
//  MainScreen.swift
//  YappProject
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import TCACoordinators

// MARK: - MainScreenCore

struct MainScreen: ReducerProtocol {
  enum State: Equatable {
    /// 메인 페이지
    case main(YappProject.State)
  }

  enum Action {
    case main(YappProject.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: /State.main,
      action: /Action.main
    ) {
      YappProject()
    }
  }
}
