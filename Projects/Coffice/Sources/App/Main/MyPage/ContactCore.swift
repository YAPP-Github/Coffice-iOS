//
//  OpenSourcesCore.swift
//  Cafe
//
//  Created by Min Min on 2023/06/13.
//  Copyright (c) 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct Contact: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()

    let title = "문의하기"
  }

  enum Action: Equatable {
    case onAppear
    case popView
  }

  var body: some ReducerProtocolOf<Contact> {
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
