//
//  LocationServiceTermsCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct LocationServiceTerms: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()
    var webViewState: CommonWebReducer.State
    let title = "위치서비스 약관"
    let webUrlString = "https://traveling-jade-4ad.notion.site/f946b1a337704f108f11d3c6333569d8"

    init() {
      webViewState = .init(urlString: webUrlString)
    }
  }

  enum Action: Equatable {
    case onAppear
    case popView
    case webAction(CommonWebReducer.Action)
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<LocationServiceTerms> {
    Scope(
      state: \.webViewState,
      action: /Action.webAction
    ) {
      CommonWebReducer()
    }

    Reduce { _, action in
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
