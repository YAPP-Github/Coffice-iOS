//
//  LoginServiceTermsBottomSheetCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/20.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct LoginServiceTermsBottomSheet: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()
  }

  enum Action: Equatable {
    case onAppear
    case dismissView
  }

  var body: some ReducerProtocolOf<LoginServiceTermsBottomSheet> {
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
