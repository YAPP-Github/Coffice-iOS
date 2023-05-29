//
//  SavedListCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct SavedList: ReducerProtocol {
  struct State: Equatable {
    let title = "SavedList"
  }

  enum Action: Equatable {
    case onAppear
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<SavedList> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none
      }
    }
  }
}
