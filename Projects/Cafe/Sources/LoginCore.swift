//
//  LoginCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct Login: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()

    let title = "Login"
  }

  enum Action: Equatable {
    case onAppear
    case useAppAsNonMember
    case kakaoLoginButtonClicked
    case appleLoginButtonClicked
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none

      default:
        return .none
      }
    }
  }
}
