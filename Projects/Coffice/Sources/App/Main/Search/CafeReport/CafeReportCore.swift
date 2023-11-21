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
    var mandatoryOptionCellStates: [MandatoryOptionCellState] = [
      .init(optionType: .outlet(.unknown)),
      .init(optionType: .spaceSize(.unknown)),
      .init(optionType: .groupSeat(.unknown))
    ]
    var optionalOptionCellStates: [OptionalOptionCellState] = [
      .init(optionType: .food(.unknown)),
      .init(optionType: .restroom(.unknown)),
      .init(optionType: .drink(.unknown))
    ]

    let textViewDidBeginEditingScrollId = UUID()
    let maximumTextLength = 200
    var textViewBottomPadding: CGFloat = 0.0
    var currentTextLengthDescription: String { "\(reviewText?.count ?? 0)" }
    var maximumTextLengthDescription: String { "/\(maximumTextLength)" }
    var shouldPresentTextViewPlaceholder: Bool {
      reviewText?.isEmpty != false
    }
    let textViewPlaceholder = """
                              혼자서 오기 좋았나요?
                              테이블, 의자는 편했나요?
                              카페에서 작업하며 느꼈던 점들을 공유해주세요!
                              """

    @BindingState var cafeReportSearchState: CafeReportSearch.State?
    @BindingState var reviewText: String?
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case popView
    case cafeSearchButtonTapped
    case presentCafeReportSearchView
    case cafeReportSearch(CafeReportSearch.Action)
    case updateTextViewBottomPadding(isTextViewEditing: Bool)
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

      case .updateTextViewBottomPadding(let isTextViewEditing):
        state.textViewBottomPadding = isTextViewEditing ? 200 : 0
        return .none

      default:
        return .none
      }
    }
  }
}

extension CafeReport {
  enum MandatoryOption: Equatable {
    /// 콘센트
    case outlet(ElectricOutletLevel)
    /// 공간크기
    case spaceSize(CapacityLevel)
    /// 단체석
    case groupSeat(CafeGroupSeatLevel)
  }

  enum OptionalOption: Equatable {
    /// 푸드
    case food(FoodType)
    /// 화장실
    case restroom(RestroomType)
    /// 음료
    case drink(DrinkType)
  }

  struct MandatoryOptionCellState: Equatable, Identifiable {
    let id = UUID()
    let optionType: CafeReport.MandatoryOption
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
        let outletLevels: [ElectricOutletLevel] = [.many, .several, .few]
        return outletLevels.map { level in
          return .init(
            title: level.informationText,
            isSelected: level == selectedLevel
          )
        }
      case .spaceSize(let selectedLevel):
        let capacityLevels: [CapacityLevel] = [.high, .medium, .low]
        return capacityLevels.map { level in
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

  struct OptionalOptionCellState: Equatable, Identifiable {
    let id = UUID()
    let optionType: CafeReport.OptionalOption
    var title: String {
      switch optionType {
      case .food: "푸드"
      case .restroom: "화장실"
      case .drink: "음료"
      }
    }

    var optionButtonStates: [CafeReport.OptionButtonState] {
      switch optionType {
      case .food(let selectedOption):
        let foodTypes: [FoodType] = [.dessert, .mealWorthy]
        return foodTypes.map { type in
          return .init(
            title: type.text,
            isSelected: type == selectedOption
          )
        }
      case .restroom(let selectedOption):
        let restroomTypes: [RestroomType] = [.indoors, .genderSeperated]
        return restroomTypes.map { type in
          return .init(
            title: type.text,
            isSelected: type == selectedOption
          )
        }
      case .drink(let selectedOption):
        let drinkTypes: [DrinkType] = [.decaffeinated, .soyMilk]
        return drinkTypes.map { type in
          return .init(
            title: type.text,
            isSelected: type == selectedOption
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
