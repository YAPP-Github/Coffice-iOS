//
//  CafeReviewWriteCore.swift
//  coffice
//
//  Created by Min Min on 2023/06/29.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct CafeReviewWrite: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()
  }

  enum Action: Equatable {
    case onAppear
    case dismissView
  }

  var body: some ReducerProtocolOf<CafeReviewWrite> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      default:
        return .none
      }
    }
  }
}
