//
//  SearchCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct Search: ReducerProtocol {
  struct State: Equatable {
    let title = "Search"
  }

  enum Action: Equatable {
    case onAppear
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<Search> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none
      }
    }
  }
}
