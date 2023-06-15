//
//  PrivacyPolicyCore.swift
//  Cafe
//
//  Created by Min Min on 2023/06/15.
//  Copyright (c) 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct PrivacyPolicy: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()

    let title = "개인정보 처리방침"
  }

  enum Action: Equatable {
    case onAppear
    case popView
  }

  var body: some ReducerProtocolOf<PrivacyPolicy> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .popView:
        return .none
      }
    }
  }
}
