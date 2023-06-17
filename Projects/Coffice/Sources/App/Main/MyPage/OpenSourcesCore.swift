//
//  OpenSourcesCore.swift
//  Cafe
//
//  Created by Min Min on 2023/06/13.
//  Copyright (c) 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct OpenSources: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()

    let title = "오픈소스 라이브러리"
  }

  enum Action: Equatable {
    case onAppear
    case popView
  }

  var body: some ReducerProtocolOf<OpenSources> {
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
