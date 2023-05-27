//
//  AppScreenCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import TCACoordinators

// MARK: - MainScreenCore

struct AppScreen: ReducerProtocol {
  enum State: Equatable {
    /// 메인 페이지
    case main(MainCoordinator.State)
  }

  enum Action: Equatable {
    case main(MainCoordinator.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: /State.main,
      action: /Action.main
    ) {
      MainCoordinator()
    }
  }
}
