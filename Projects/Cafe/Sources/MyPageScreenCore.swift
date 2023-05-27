//
//  MyPageScreenCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import TCACoordinators

// MARK: - MainScreenCore

struct MyPageScreen: ReducerProtocol {
  enum State: Equatable {
    /// 메인 페이지
    case myPage(MyPage.State)
  }

  enum Action: Equatable {
    case myPage(MyPage.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: /State.myPage,
      action: /Action.myPage
    ) {
      MyPage()
    }
  }
}
