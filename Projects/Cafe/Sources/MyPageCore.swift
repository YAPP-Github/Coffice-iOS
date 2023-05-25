//
//  MyPageCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct MyPage: ReducerProtocol {
  struct State: Equatable {
    let title = "MyPage"
  }

  enum Action: Equatable {
    case onAppear
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
      }
    }
  }
}
