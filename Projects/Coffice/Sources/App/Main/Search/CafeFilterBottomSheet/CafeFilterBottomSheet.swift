//
//  CafeFilterBottomSheet.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct CafeFilterBottomSheet: ReducerProtocol {
  typealias OptionType = CafeFilterOptionButtonViewState.OptionType
  typealias RunningTimeOption = CafeFilterOptionButtonViewState.RunningTimeOption
  typealias OutletOption = CafeFilterOptionButtonViewState.OutletOption
  typealias SpaceSizeOption = CafeFilterOptionButtonViewState.SpaceSizeOption
  typealias PersonnelOption = CafeFilterOptionButtonViewState.PersonnelOption
  typealias FoodOption = CafeFilterOptionButtonViewState.FoodOption
  typealias ToiletOption = CafeFilterOptionButtonViewState.ToiletOption
  typealias DrinkOption = CafeFilterOptionButtonViewState.DrinkOption

  struct State: Equatable {
    static var mock: Self {
      .init(filterType: .detail)
    }

    let filterType: CafeFilterType
    var mainViewState: CafeFilterBottomSheetViewState = .init(optionButtonCellViewStates: [])

    let headerViewHeight: CGFloat = 80
    let footerViewHeight: CGFloat = 84
    var scrollViewHeight: CGFloat {
      switch filterType {
      case .detail:
        return 435
      default:
        return 76
      }
    }

    init(filterType: CafeFilterType) {
      self.filterType = filterType

      switch filterType {
      case .detail:
        mainViewState = .init(
          optionButtonCellViewStates: [
            runningTimeOptionButtonCellViewState,
            outletOptionButtonCellViewState,
            spaceSizeOptionButtonCellViewState,
            personnelOptionButtonCellViewState,
            foodOptionButtonCellViewState,
            toiletOptionButtonCellViewState,
            drinkOptionButtonCellViewState
          ]
        )
      case .runningTime:
        mainViewState = .init(optionButtonCellViewStates: [runningTimeOptionButtonCellViewState])
      case .outlet:
        mainViewState = .init(optionButtonCellViewStates: [outletOptionButtonCellViewState])
      case .spaceSize:
        mainViewState = .init(optionButtonCellViewStates: [spaceSizeOptionButtonCellViewState])
      case .personnel:
        mainViewState = .init(optionButtonCellViewStates: [personnelOptionButtonCellViewState])
      }
    }

    // TODO: 음료, 화장실, 단체석, 푸드 구현
    var runningTimeOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      CafeFilterOptionButtonCellViewState(
        viewStates: RunningTimeOption.allCases.map {
          CafeFilterOptionButtonViewState(optionType: .runningTime($0), buttonTitle: $0.title)
        }
      )
    }

    var outletOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      CafeFilterOptionButtonCellViewState(
        viewStates: OutletOption.allCases.map {
          CafeFilterOptionButtonViewState(optionType: .outlet($0), buttonTitle: $0.title)
        }
      )
    }

    var spaceSizeOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      CafeFilterOptionButtonCellViewState(
        viewStates: SpaceSizeOption.allCases.map {
          CafeFilterOptionButtonViewState(optionType: .spaceSize($0), buttonTitle: $0.title)
        }
      )
    }

    var personnelOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      CafeFilterOptionButtonCellViewState(
        viewStates: PersonnelOption.allCases.map {
          CafeFilterOptionButtonViewState(optionType: .personnel($0), buttonTitle: $0.title)
        }
      )
    }

    var foodOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      CafeFilterOptionButtonCellViewState(
        viewStates: FoodOption.allCases.map {
          CafeFilterOptionButtonViewState(optionType: .food($0), buttonTitle: $0.title)
        }
      )
    }

    var toiletOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      CafeFilterOptionButtonCellViewState(
        viewStates: ToiletOption.allCases.map {
          CafeFilterOptionButtonViewState(optionType: .toilet($0), buttonTitle: $0.title)
        }
      )
    }

    var drinkOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      CafeFilterOptionButtonCellViewState(
        viewStates: DrinkOption.allCases.map {
          CafeFilterOptionButtonViewState(optionType: .drink($0), buttonTitle: $0.title)
        }
      )
    }

    var shouldShowSubSectionView: Bool {
      return filterType == .detail
    }

    var bottomSheetHeight: CGFloat {
      headerViewHeight + scrollViewHeight + footerViewHeight
    }
  }

  enum Action: Equatable {
    case findTappedButton(UUID)
    // TODO: filterButton 적용, 초기화
    case optionButtonTapped(collectionIndex: Int, optionType: OptionType)
    case filterOptionRequest
    case dismiss
    case searchPlaces
    case searchPlacesResponse(TaskResult<Int>)
    case resetFilter(CafeFilterType)
    case infoGuideButtonTapped
    case presentBubbleMessageView(BubbleMessage.State)
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeFilterBottomSheet> {
    Reduce { state, action in
      switch action {
      case let .optionButtonTapped(collectionIndex, optionType):
        state.mainViewState
          .optionButtonCellViewStates[collectionIndex].viewStates[optionType.index]
          .isSelected
          .toggle()
        return .none

      case .infoGuideButtonTapped:
        // TODO: 상세 필터 타입에 맞게 말풍선뷰 표출 필요
        return EffectTask(value: .presentBubbleMessageView(.mock))

      default:
        return .none
      }
    }
  }
}
