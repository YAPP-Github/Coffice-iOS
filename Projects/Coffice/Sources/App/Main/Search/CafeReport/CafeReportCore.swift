//
//  CafeReportCore.swift
//  coffice
//
//  Created by Min Min on 11/2/23.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct CafeReport: Reducer {
  struct State: Equatable {
    static let initialState: State = .init()
    let title = "신규 카페 제보하기"

    @BindingState var cafeReportSearchState: CafeReportSearch.State?
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case popView
    case cafeSearchButtonTapped
    case presentCafeReportSearchView
    case cafeReportSearch(CafeReportSearch.Action)
  }

  var body: some ReducerOf<CafeReport> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .cafeSearchButtonTapped:
        state.cafeReportSearchState = .init()
        return .none

      case .cafeReportSearch(.dismiss):
        state.cafeReportSearchState = nil
        return .none

      default:
        return .none
      }
    }
  }
}
