//
//  FilterSheetCore.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct OptionButton: Equatable {
  var id: UUID
  var optionType: OptionType
  var buttonType: ButtonType
  var buttonTitle: String = ""
  var savedTappedState: Bool = false
  var currentTappedState: Bool = false
  var foregroundColor: CofficeColors {
    if currentTappedState {
      return CofficeAsset.Colors.grayScale9
    } else {
      return CofficeAsset.Colors.grayScale7
    }
  }
  var backgroundColor: CofficeColors {
    if currentTappedState {
      return CofficeAsset.Colors.grayScale9
    } else {
      return CofficeAsset.Colors.grayScale1
    }
  }

  init(id: UUID, buttonType: ButtonType, optionType: OptionType, buttonTitle: String) {
    self.id = id
    self.optionType = optionType
    self.buttonType = buttonType
    self.buttonTitle = buttonTitle
  }

  enum OptionType: Equatable {
    case outlet
    case spaceSize
    case food
    case drink
    case toilet
  }

  enum ButtonType: Equatable {
    case outlet(OutletButton)
    case spaceSize(SpaceSizeButton)
    case food
    case drink
    case toilet
  }

  enum SpaceSizeButton: Equatable, CaseIterable {
    case large
    case midium
    case small
  }

  enum RestroomButton: Equatable, CaseIterable {
    case indoors
    case genderSeparated
  }

  enum OutletButton: Equatable, CaseIterable {
    case many
    case several
    case few

    var name: String {
      switch self {
      case .many: return "넉넉"
      case .several: return "보통"
      case .few: return "부족"
      }
    }
  }
}

struct FilterSheetCore: ReducerProtocol {
  struct State: Equatable {
    var filterType: FilterType = .none
    // TODO: 음료, 화장실, 단체석, 푸드 구현
    var outletButtonViewState: [OptionButton] = OptionButton.OutletButton.allCases.map {
      OptionButton(id: UUID(), buttonType: .outlet($0), optionType: .outlet, buttonTitle: $0.name)
    }

    var spaceSizeButtonViewState: [OptionButton] = OptionButton.SpaceSizeButton.allCases.map {
      OptionButton(id: UUID(), buttonType: .spaceSize($0), optionType: .spaceSize, buttonTitle: "")
    }
  }

  enum Action: Equatable {
    case findTappedButton(UUID)
    // TODO: filterButton 적용, 초기화
    case buttonTapped(Int, OptionButton.OptionType)
    case filterOptionRequest
    case dismiss
    case searchPlaces
    case searchPlacesResponse(TaskResult<Int>)
    case resetFilter(FilterType)
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<FilterSheetCore> {
    Reduce { state, action in
      switch action {
      // TODO: action 동작 정의 MainCoordinatorCore에 구현
      case .buttonTapped(let idx, let optionType):
        switch optionType {
        case .outlet:
          state.outletButtonViewState[idx].currentTappedState.toggle()
          return .none

        case .spaceSize:
          state.spaceSizeButtonViewState[idx].currentTappedState.toggle()
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
  // 어떤 FilterSheet인지 구분하도록 FilterType 설정
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
      case .personnel: return "단체석"
      case .spaceSize: return "공간크기"
      case .cafeDetailFilter: return "세부필터"
      case .none: return ""
      }
    }
  }
}
