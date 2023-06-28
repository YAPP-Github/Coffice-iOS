//
//  CafeSearchCore.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct CafeSearchListCore: ReducerProtocol {
  struct State: Equatable {
    let filterOrders = FilterSheetCore.FilterType.allCases
    var filterSheetState = FilterSheetCore.State(filterType: .cafeDetailFilter)
  }

  enum Action: Equatable {
    case presentFilterSheetView(FilterSheetCore.State)
    case filterButtonTapped(FilterSheetCore.FilterType)
    case dismiss
    case popView
  }

  var body: some ReducerProtocolOf<CafeSearchListCore> {
    Reduce { state, action in
      switch action {
      case .filterButtonTapped(let filterButton):
        state.filterSheetState.filterType = filterButton
        return EffectTask(value: .presentFilterSheetView(state.filterSheetState))
      default:
        return .none
      }
    }
  }
}
