//
//  CafeFilterBottomSheetViewState.swift
//  coffice
//
//  Created by Min Min on 2023/07/06.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

struct CafeFilterBottomSheetViewState: Equatable {
  var optionButtonCellViewStates: [CafeFilterOptionButtonCellViewState]

  init(optionButtonCellViewStates: [CafeFilterOptionButtonCellViewState]) {
    self.optionButtonCellViewStates = optionButtonCellViewStates
  }
}

struct CafeFilterOptionButtonViewState: Equatable, Identifiable {
  let id = UUID()
  var option: CafeFilter.OptionType
  var buttonTitle: String = ""
  var savedTappedState: Bool = false
  var isSelected: Bool = false
  var foregroundColor: CofficeColors {
    if isSelected {
      return CofficeAsset.Colors.grayScale1
    } else {
      return CofficeAsset.Colors.grayScale7
    }
  }
  var backgroundColor: CofficeColors {
    if isSelected {
      return CofficeAsset.Colors.grayScale9
    } else {
      return CofficeAsset.Colors.grayScale1
    }
  }
  var borderColor: CofficeColors {
    if isSelected {
      return CofficeAsset.Colors.grayScale9
    } else {
      return CofficeAsset.Colors.grayScale4
    }
  }

  init(optionType: CafeFilter.OptionType, buttonTitle: String, isSelected: Bool = false) {
    self.option = optionType
    self.buttonTitle = buttonTitle
    self.isSelected = isSelected
  }
}

struct CafeFilterOptionButtonCellViewState: Equatable, Identifiable {
  let id = UUID()
  var viewStates: [CafeFilterOptionButtonViewState]
  var sectionTitle: String {
    switch viewStates.first?.option {
    case .runningTime(let option):
      return option.sectionTitle
    case .outlet(let option):
      return option.sectionTitle
    case .spaceSize(let option):
      return option.sectionTitle
    case .personnel(let option):
      return option.sectionTitle
    case .food(let option):
      return option.sectionTitle
    case .toilet(let option):
      return option.sectionTitle
    case .drink(let option):
      return option.sectionTitle
    case .none:
      return "-"
    }
  }
}

enum CafeFilter {
  enum OptionType: Equatable {
    /// 영업시간
    case runningTime(RunningTimeOption)
    /// 콘센트
    case outlet(OutletOption)
    /// 공간크기
    case spaceSize(SpaceSizeOption)
    /// 단체석
    case personnel(PersonnelOption)
    /// 푸드
    case food(FoodOption)
    /// 화장실
    case toilet(ToiletOption)
    /// 음료
    case drink(DrinkOption)

    var index: Int {
      switch self {
      case .runningTime(let option):
        return option.index
      case .outlet(let option):
        return option.index
      case .spaceSize(let option):
        return option.index
      case .personnel(let option):
        return option.index
      case .food(let option):
        return option.index
      case .toilet(let option):
        return option.index
      case .drink(let option):
        return option.index
      }
    }
  }

  enum GuideType: Equatable {
    case outletState
    case spaceSize
    case groupSeat
  }

  enum MenuType: CaseIterable {
    case detail
    case runningTime
    case outlet
    case spaceSize
    case personnel

    var title: String {
      switch self {
      case .detail: return "세부필터"
      case .runningTime: return "영업시간"
      case .outlet: return "콘센트"
      case .spaceSize: return "공간크기"
      case .personnel: return "단체석"
      }
    }

    var size: (width: CGFloat, height: CGFloat) {
      switch self {
      case .detail: return (width: 56, height: 36)
      case .runningTime: return (width: 91, height: 36)
      case .outlet: return (width: 79, height: 36)
      case .spaceSize: return (width: 91, height: 36)
      case .personnel: return (width: 69, height: 36)
      }
    }
  }

  enum OutletOption: Int, Equatable, CaseIterable {
    case many
    case several
    case few

    var sectionTitle: String {
      return "콘센트"
    }

    var title: String {
      switch self {
      case .many: return "넉넉"
      case .several: return "보통"
      case .few: return "부족"
      }
    }

    var index: Int {
      return rawValue
    }
  }

  enum RunningTimeOption: Int, Equatable, CaseIterable {
    case running
    case twentyFourHours

    var sectionTitle: String {
      return "영업시간"
    }

    var title: String {
      switch self {
      case .running:
        return "영업중"
      case .twentyFourHours:
        return "24시간"
      }
    }

    var index: Int {
      return rawValue
    }
  }

  enum SpaceSizeOption: Int, Equatable, CaseIterable {
    case large
    case medium
    case small

    var sectionTitle: String {
      return "공간크기"
    }

    var title: String {
      switch self {
      case .large:
        return "대형카페"
      case .medium:
        return "중형카페"
      case .small:
        return "소형카페"
      }
    }

    var index: Int {
      return rawValue
    }
  }

  enum PersonnelOption: Int, Equatable, CaseIterable {
    case groupSeat

    var sectionTitle: String {
      return "단체석"
    }

    var title: String {
      return "단체석"
    }

    var index: Int {
      return rawValue
    }
  }

  enum FoodOption: Int, Equatable, CaseIterable {
    case desert
    case mealAvailable

    var sectionTitle: String {
      return "푸드"
    }

    var title: String {
      switch self {
      case .desert:
        return "디저트"
      case .mealAvailable:
        return "식사가능"
      }
    }

    var index: Int {
      return rawValue
    }
  }

  enum ToiletOption: Int, Equatable, CaseIterable {
    case indoors
    case genderSeparated

    var sectionTitle: String {
      return "화장실"
    }

    var title: String {
      switch self {
      case .indoors:
        return "실내"
      case .genderSeparated:
        return "남녀개별"
      }
    }

    var index: Int {
      return rawValue
    }
  }

  enum DrinkOption: Int, Equatable, CaseIterable {
    case decaf
    case soyMilk

    var sectionTitle: String {
      return "음료"
    }

    var title: String {
      switch self {
      case .decaf:
        return "디카페인"
      case .soyMilk:
        return "두유"
      }
    }

    var index: Int {
      return rawValue
    }
  }
}
