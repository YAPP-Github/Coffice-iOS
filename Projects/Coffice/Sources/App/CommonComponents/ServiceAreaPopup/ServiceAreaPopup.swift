//
//  ServiceAreaPopup.swift
//  coffice
//
//  Created by sehooon on 2023/07/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct ServiceAreaPopup: Reducer {
  struct State: Equatable { }

  enum Action: Equatable {
    case confirmButtonTapped
  }

  var body: some ReducerOf<ServiceAreaPopup> {
    Reduce { state, action in
      switch action {
      default:
        return .none
      }
    }
  }
}
