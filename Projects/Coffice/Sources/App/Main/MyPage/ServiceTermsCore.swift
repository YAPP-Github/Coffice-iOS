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

    let title = "위치서비스 약관"
  }

  enum Action: Equatable {
    case onAppear
    case popView
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<LocationServiceTerms> {
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
