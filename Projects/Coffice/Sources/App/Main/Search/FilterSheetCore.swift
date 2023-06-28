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
    var filterType: FilterType = .none
    var cafeSizeFilterButtons  = CafeSizeFilterButton.allCases
    var cafeOutletFilterButtons = CafeOutletFilterButton.allCases
    var cafeOperationHourFilterButtons = CafeOperationHourFilterButton.allCases
    var cafePersonnelFilterButtons = CafePersonnelFilterButton.allCases
  }

  enum Action: Equatable {
    case dismiss
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
        case .runningTime:
          state.filterType = .runningTime
          return .none

        case .outlet:
          state.filterType = .outlet
          return .none

        case .spaceSize:
          state.filterType = .spaceSize
          return .none

        case .personnel:
          state.filterType = .personnel
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
      case .enough: return "넉넉(80%)"
      case .some: return "보통(50%)"
      case .little: return "부족(10%)"
      case .none: return ""
      }
    }
  }

  enum CafeSizeFilterButton: CaseIterable {
    case large
    case medium
    case small
    case none

    var name: String {
      switch self {
      case .large: return "대형"
      case .medium: return "중형"
      case .small: return "소형"
      case .none: return ""
      }
    }
  }

  enum CafeOperationHourFilterButton: CaseIterable {
    case clock
    case onTime
    case twentyFourHours
    case none

    var name: String {
      switch self {
      case .clock: return "넉넉(80%)"
      case .onTime: return "영업중"
      case .twentyFourHours: return "24시간"
      case .none: return ""
      }
    }
  }

  enum CafePersonnelFilterButton: CaseIterable {
    case moreFivePeople
    case none

    var name: String {
      switch self {
      case .moreFivePeople: return "5인이상"
      case .none: return ""
      }
    }
  }

  enum FilterType: CaseIterable {
    case outlet
    case runningTime
    case spaceSize
    case cafeDetailFilter
    case personnel
    case none

    var titleName: String {
      switch self {
      case .outlet: return "콘센트"
      case .runningTime: return "영업시간"
      case .personnel: return "인원"
      case .spaceSize: return "공간크기"
      case .cafeDetailFilter: return "세부필터"
      case .none: return ""
      }
    }
  }
}
