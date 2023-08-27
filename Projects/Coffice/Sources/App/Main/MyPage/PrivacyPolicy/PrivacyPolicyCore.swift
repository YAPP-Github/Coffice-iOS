//
//  PrivacyPolicyCore.swift
//  Cafe
//
//  Created by Min Min on 2023/06/15.
//  Copyright (c) 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct PrivacyPolicy: Reducer {
  struct State: Equatable {
    static let initialState: State = .init()
    var webViewState: CommonWebReducer.State
    let webUrlString = "https://traveling-jade-4ad.notion.site/74a66cfd0dc34c17b0f2f8da4f1cd1bb"
    let title = "개인정보 처리방침"

    init() {
      webViewState = .init(urlString: webUrlString)
    }
  }

  enum Action: Equatable {
    case onAppear
    case popView
    case webAction(CommonWebReducer.Action)
  }

  var body: some ReducerOf<PrivacyPolicy> {
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

      case .webAction:
        return .none

      case .popView:
        return .none
      }
    }
  }
}
