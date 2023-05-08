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
    case second(Second.State)
    case third(Third.State)
    case modal(Modal.State)
  }

  enum Action {
    case main(YappProject.Action)
    case second(Second.Action)
    case third(Third.Action)
    case modal(Modal.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: /State.main,
      action: /Action.main
    ) {
      YappProject()
    }

    Scope(
      state: /State.second,
      action: /Action.second
    ) {
      Second()
    }

    Scope(
      state: /State.third,
      action: /Action.third
    ) {
      Third()
    }

    Scope(
      state: /State.modal,
      action: /Action.modal
    ) {
      Modal()
    }
  }
}
