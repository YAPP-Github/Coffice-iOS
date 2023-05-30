//
//  ServiceTermsCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct ServiceTerms: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()

    let title = "서비스 이용 약관"
  }

  enum Action: Equatable {
    case onAppear
    case popView
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<ServiceTerms> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none

      case .popView:
        return .none
      }
    }
  }
}
