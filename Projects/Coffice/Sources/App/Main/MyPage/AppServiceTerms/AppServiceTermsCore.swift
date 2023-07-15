//
//  AppServiceTermsCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/16.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct AppServiceTermsReducer: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()
    let title = "서비스 이용약관"
  }

  enum Action: Equatable {
    case onAppear
    case popView
  }

  var body: some ReducerProtocolOf<Self> {
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
