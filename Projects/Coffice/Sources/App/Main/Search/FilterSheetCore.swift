//
//  FilterSheetCore.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct FilterSheetCore: ReducerProtocol {
  struct State: Equatable {
    var none: [Int] = []
    var filterType: FilterType = .outletFilter
    var cafeSizeFilterButtons  = CafeSizeFilterButton.allCases
    var cafeOutletFilterButtons = CafeOutletFilterButton.allCases
    var cafeOperationHourFilterButtons = CafeOperationHourFilterButton.allCases
    var cafePersonnelFilterButtons = CafePersonnelFilterButton.allCases
  }

  enum Action: Equatable {
    case filterCategoryButtonTapped(FilterType)
    case cafeOutletFilterButtonTapped(CafeOutletFilterButton)
    case cafeSizeFilterButtonTapped(CafeSizeFilterButton)
    case cafeOperationHourFilterButtonTapped(CafeOperationHourFilterButton)
  }

  var body: some ReducerProtocolOf<FilterSheetCore> {
    Reduce { state, action in
      switch action {
      case .filterCategoryButtonTapped(let filterType):
        switch filterType {
        case .cafeOperationHourFilter:
          state.filterType = .cafeOperationHourFilter
          return .none

        case .outletFilter:
          state.filterType = .outletFilter
          return .none

        case .cafeSizeFilter:
          state.filterType = .cafeSizeFilter
          return .none

        case .cafePersonnelFilter:
          state.filterType = .cafePersonnelFilter
          return .none

        case .cafeDetailFilter:
          return .none

        default:
          return .none
        }

      default:
        return .none
      }
    }
  }
}

extension FilterSheetCore {
  enum CafeDetailFilterButton: CaseIterable {

  }

  enum CafeOutletFilterButton: CaseIterable {
    case enough
    case some
    case little
    case none

    var name: String {
      switch self {
      case .enough:
        return "넉넉(80%)"
      case .some:
        return "보통(50%)"
      case .little:
        return "부족(10%)"
      case .none:
        return ""
      }
    }
  }

  enum CafeSizeFilterButton: CaseIterable {
    case large
    case middle
    case small
    case none
  }

  enum CafeOperationHourFilterButton: CaseIterable {
    case clock
    case onTime
    case twentyFourHours
    case none
  }

  enum CafePersonnelFilterButton: CaseIterable {
    case moreFivePeople
    case none
  }

  enum FilterType {
    case outletFilter
    case cafeOperationHourFilter
    case cafeSizeFilter
    case cafeDetailFilter
    case cafePersonnelFilter
    case none
    var titleName: String {
      switch self {
      case .outletFilter:
        return "콘센트"
      case .cafeOperationHourFilter:
        return "영업시간"
      case .cafePersonnelFilter:
        return "인원"
      case .cafeSizeFilter:
        return "공간크기"
      case .cafeDetailFilter:
        return "세부필터"
      case .none:
        return ""
      }
    }
  }
}
