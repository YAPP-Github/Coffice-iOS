//
//  CafeReportCore.swift
//  coffice
//
//  Created by Min Min on 11/2/23.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeReport: Reducer {
  struct State: Equatable {
    static let initialState: State = .init()
    let title = "신규 카페 제보하기"
    var cafeReportOptionCellStates: [MandatoryOptionCellState] = [
      .init(optionType: .outlet(.unknown)),
      .init(optionType: .spaceSize(.unknown)),
      .init(optionType: .groupSeat(.unknown))
    ]

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

extension CafeReport {
  enum OptionType: Equatable {
    /// 콘센트
    case outlet(ElectricOutletLevel)
    /// 공간크기
    case spaceSize(CapacityLevel)
    /// 단체석
    case groupSeat(CafeGroupSeatLevel)
  }

  struct MandatoryOptionCellState: Equatable, Identifiable {
    let id = UUID()
    let optionType: CafeReport.OptionType
    var title: String {
      switch optionType {
      case .outlet: "콘센트 🔌"
      case .spaceSize: "공간 크기 ☕️"
      case .groupSeat: "단체석 🪑"
      }
    }

    var description: String {
      switch optionType {
      case .outlet: "좌석대비 콘센트 비율"
      case .spaceSize: "테이블 개수 기준"
      case .groupSeat: "5인이상 단체석"
      }
    }

    var optionButtonStates: [CafeReport.OptionButtonState] {
      switch optionType {
      case .outlet(let selectedLevel):
        let outletLevel: [ElectricOutletLevel] = [.many, .several, .few]
        return outletLevel.map { level in
          return .init(
            title: level.informationText,
            isSelected: level == selectedLevel
          )
        }
      case .spaceSize(let selectedLevel):
        let capacityLevel: [CapacityLevel] = [.high, .medium, .low]
        return capacityLevel.map { level in
          return .init(
            title: level.informationText,
            isSelected: level == selectedLevel
          )
        }
      case .groupSeat(let selectedSeatType):
        let seatTypes: [CafeGroupSeatLevel] = [.isTrue, .isFalse]
        return seatTypes.map { type in
          return .init(
            title: type.detailOptionText,
            isSelected: type == selectedSeatType
          )
        }
      }
    }
  }
}

extension CafeReport {
  struct OptionButtonState: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let isSelected: Bool

    var titleFont: CofficeFont {
      .body2Medium
    }

    var foregroundColor: CofficeColors {
      isSelected
      ? CofficeAsset.Colors.grayScale1
      : CofficeAsset.Colors.grayScale7
    }

    var backgroundColor: CofficeColors {
      isSelected
      ? CofficeAsset.Colors.grayScale9
      : CofficeAsset.Colors.grayScale1
    }

    var borderColor: CofficeColors {
      isSelected
      ? CofficeAsset.Colors.grayScale9
      : CofficeAsset.Colors.grayScale4
    }
  }
}
