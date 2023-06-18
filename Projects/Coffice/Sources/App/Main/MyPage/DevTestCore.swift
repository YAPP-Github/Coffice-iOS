//
//  DevTestCore.swift
//  Cafe
//
//  Created by Min Min on 2023/06/13.
//  Copyright (c) 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct DevTest: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()

    let title = "개발자 기능 테스트"
  }

  enum Action: Equatable {
    case onAppear
    case popView
  }

  var body: some ReducerProtocolOf<DevTest> {
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
