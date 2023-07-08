//
//  CafeFilterBottomSheet.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeFilterBottomSheet: ReducerProtocol {
  typealias OptionType = CafeFilter.OptionType
  typealias RunningTimeOption = CafeFilter.RunningTimeOption
  typealias OutletOption = CafeFilter.OutletOption
  typealias SpaceSizeOption = CafeFilter.SpaceSizeOption
  typealias PersonnelOption = CafeFilter.PersonnelOption
  typealias FoodOption = CafeFilter.FoodOption
  typealias ToiletOption = CafeFilter.ToiletOption
  typealias DrinkOption = CafeFilter.DrinkOption

  struct State: Equatable {
    static var mock: Self {
      .init(
        filterType: .detail,
        cafeFilterIntormation: .mock
      )
    }

    let filterType: CafeFilter.BottomSheetType
    /// 기존 필터 설정 상태
    var originCafeFilterInformation: CafeFilterInformation
    var cafeFilterInformation: CafeFilterInformation
    var mainViewState: CafeFilterBottomSheetViewState = .init(optionButtonCellViewStates: [])

    var isBottomSheetPresented = false
    let dismissAnimationDuration: Double = 0.3
    let dismissDelayNanoseconds: UInt64 = 300_000_000
    var containerViewHeight: CGFloat = .zero
    let headerViewHeight: CGFloat = 80
    let footerViewHeight: CGFloat = 84 + (UIApplication.keyWindow?.safeAreaInsets.bottom ?? 0.0)
    var scrollViewHeight: CGFloat {
      switch filterType {
      case .detail:
        return 435
      default:
        return 76
      }
    }

    init(filterType: CafeFilter.BottomSheetType, cafeFilterIntormation: CafeFilterInformation) {
      self.filterType = filterType
      self.originCafeFilterInformation = cafeFilterIntormation
      self.cafeFilterInformation = cafeFilterIntormation
      updateMainViewState()
    }

    mutating func updateMainViewState() {
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

    var runningTimeOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      .init(
        viewStates: RunningTimeOption.allCases.map {
          CafeFilterOptionButtonViewState(
            optionType: .runningTime($0),
            buttonTitle: $0.title,
            isSelected: cafeFilterInformation.runningTimeOptionSet.contains($0)
          )
        }
      )
    }

    var outletOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      .init(
        viewStates: OutletOption.allCases.map {
          CafeFilterOptionButtonViewState(
            optionType: .outlet($0),
            buttonTitle: $0.title,
            isSelected: cafeFilterInformation.outletOptionSet.contains($0)
          )
        }
      )
    }

    var spaceSizeOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      .init(
        viewStates: SpaceSizeOption.allCases.map {
          CafeFilterOptionButtonViewState(
            optionType: .spaceSize($0),
            buttonTitle: $0.title,
            isSelected: cafeFilterInformation.spaceSizeOptionSet.contains($0)
          )
        }
      )
    }

    var personnelOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      .init(
        viewStates: PersonnelOption.allCases.map {
          CafeFilterOptionButtonViewState(
            optionType: .personnel($0),
            buttonTitle: $0.title,
            isSelected: cafeFilterInformation.personnelOptionSet.contains($0)
          )
        }
      )
    }

    var foodOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      .init(
        viewStates: FoodOption.allCases.map {
          CafeFilterOptionButtonViewState(
            optionType: .food($0),
            buttonTitle: $0.title,
            isSelected: cafeFilterInformation.foodOptionSet.contains($0)
          )
        }
      )
    }

    var toiletOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      .init(
        viewStates: ToiletOption.allCases.map {
          CafeFilterOptionButtonViewState(
            optionType: .toilet($0),
            buttonTitle: $0.title,
            isSelected: cafeFilterInformation.toiletOptionSet.contains($0)
          )
        }
      )
    }

    var drinkOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
      .init(
        viewStates: DrinkOption.allCases.map {
          CafeFilterOptionButtonViewState(
            optionType: .drink($0),
            buttonTitle: $0.title,
            isSelected: cafeFilterInformation.drinkOptionSet.contains($0)
          )
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
    case dismiss
    case presentBottomSheet
    case optionButtonTapped(optionType: OptionType)
    case infoGuideButtonTapped
    case presentBubbleMessageView(BubbleMessage.State)
    case updateMainViewState
    case resetCafeFilterButtonTapped
    case resetCafeFilter
    case saveCafeFilterButtonTapped
    case backgroundViewTapped
    case updateContainerView(height: CGFloat)
    case saveCafeFilter(information: CafeFilterInformation)
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeFilterBottomSheet> {
    Reduce { state, action in
      switch action {
      case .backgroundViewTapped:
        state.isBottomSheetPresented = false
        let dismissTimeInterval = state.dismissDelayNanoseconds
        return .run { send in
          try await Task.sleep(nanoseconds: dismissTimeInterval)
          await send(.dismiss)
        }

      case .presentBottomSheet:
        state.isBottomSheetPresented = true
        return .none

      case .optionButtonTapped(let optionType):
        switch optionType {
        case .runningTime(let option):
          if state.cafeFilterInformation.runningTimeOptionSet.contains(option) {
            state.cafeFilterInformation.runningTimeOptionSet.remove(option)
          } else {
            state.cafeFilterInformation.runningTimeOptionSet.insert(option)
          }
        case .outlet(let option):
          if state.cafeFilterInformation.outletOptionSet.contains(option) {
            state.cafeFilterInformation.outletOptionSet.remove(option)
          } else {
            state.cafeFilterInformation.outletOptionSet.insert(option)
          }
        case .spaceSize(let option):
          if state.cafeFilterInformation.spaceSizeOptionSet.contains(option) {
            state.cafeFilterInformation.spaceSizeOptionSet.remove(option)
          } else {
            state.cafeFilterInformation.spaceSizeOptionSet.insert(option)
          }
        case .personnel(let option):
          if state.cafeFilterInformation.personnelOptionSet.contains(option) {
            state.cafeFilterInformation.personnelOptionSet.remove(option)
          } else {
            state.cafeFilterInformation.personnelOptionSet.insert(option)
          }
        case .food(let option):
          if state.cafeFilterInformation.foodOptionSet.contains(option) {
            state.cafeFilterInformation.foodOptionSet.remove(option)
          } else {
            state.cafeFilterInformation.foodOptionSet.insert(option)
          }
        case .toilet(let option):
          if state.cafeFilterInformation.toiletOptionSet.contains(option) {
            state.cafeFilterInformation.toiletOptionSet.remove(option)
          } else {
            state.cafeFilterInformation.toiletOptionSet.insert(option)
          }
        case .drink(let option):
          if state.cafeFilterInformation.drinkOptionSet.contains(option) {
            state.cafeFilterInformation.drinkOptionSet.remove(option)
          } else {
            state.cafeFilterInformation.drinkOptionSet.insert(option)
          }
        }
        return EffectTask(value: .updateMainViewState)

      case .infoGuideButtonTapped:
        // TODO: 상세 필터 타입에 맞게 말풍선뷰 표출 필요
        return EffectTask(value: .presentBubbleMessageView(.mock))

      case .updateMainViewState:
        state.updateMainViewState()
        return .none

      case .resetCafeFilterButtonTapped:
        return EffectTask(value: .resetCafeFilter)

      case .resetCafeFilter:
        state.cafeFilterInformation = state.originCafeFilterInformation
        return EffectTask(value: .updateMainViewState)

      case .saveCafeFilterButtonTapped:
        // TODO: 화면 상단 필터뷰로 데이터 전달하여 UI 업데이트 필요
        debugPrint("saved mainViewState : \(state.mainViewState)")
        return .concatenate(
          EffectTask(value: .saveCafeFilter(information: state.cafeFilterInformation)),
          EffectTask(value: .dismiss)
        )

      case .updateContainerView(let height):
        state.containerViewHeight = height
        return .none

      default:
        return .none
      }
    }
  }
}
