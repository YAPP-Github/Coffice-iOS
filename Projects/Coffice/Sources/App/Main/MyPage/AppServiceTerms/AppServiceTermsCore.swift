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
    var webViewState: CommonWebReducer.State
    let title = "서비스 이용약관"
    let webUrlString = "https://traveling-jade-4ad.notion.site/0b8d9c87d5be459c97860ddb4bffaa31"

    init() {
      webViewState = .init(urlString: webUrlString)
    }
  }

  enum Action: Equatable {
    case onAppear
    case popView
    case webAction(CommonWebReducer.Action)
  }

  var body: some ReducerProtocolOf<Self> {
    Scope(
      state: \.webViewState,
      action: /Action.webAction
    ) {
      CommonWebReducer()
    }

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .popView:
        return .none

      case .webAction:
        return .none
      }
    }
  }
}
