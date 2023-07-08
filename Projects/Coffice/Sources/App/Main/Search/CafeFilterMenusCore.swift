//
//  CafeFilterMenusCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/08.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct CafeFilterMenus: ReducerProtocol {
  struct State: Equatable {
    static let mock: State = .init(filterInformation: .mock)
    let filterOrders = CafeFilter.BottomSheetType.allCases
    var filterInformation: CafeFilterInformation
  }

  enum Action: Equatable {
    case onAppear
    case filterButtonTapped(CafeFilter.BottomSheetType)
    case presentFilterSheetView(CafeFilterBottomSheet.State)
  }

  var body: some ReducerProtocolOf<CafeFilterMenus> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .filterButtonTapped(let filterType):
        return EffectTask(value: .presentFilterSheetView(.init(filterType: filterType, cafeFilterIntormation: .mock)))

      default:
        return .none
      }
    }
  }
}
