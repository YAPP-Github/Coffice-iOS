//
//  CafeReportSearchCore.swift
//  coffice
//
//  Created by Min Min on 11/18/23.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeReportSearch: Reducer {
  struct State: Equatable {
    static let initialState: State = .init()
    let topPadding: CGFloat = 108
  }

  enum Action: Equatable {
    case onAppear
    case dismiss
  }

  var body: some ReducerOf<CafeReportSearch> {
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
