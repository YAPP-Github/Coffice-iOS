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
  struct State: Equatable {
    static var mock: Self {
      .init(
        filterType: .detail,
        cafeFilterInformation: .mock
      )
    }

    @BindingState var bubbleMessageViewState: BubbleMessage.State?
    let filterType: CafeFilter.MenuType
    var guideType: CafeFilter.GuideType? {
      switch filterType {
      case .outlet:
        return .outletState
      case .spaceSize:
        return .spaceSize
      case .personnel:
        return .groupSeat
      default:
        return nil
      }
    }

    var shouldShowGuideButton: Bool {
      return guideType != nil
    }

    /// 기존 필터 설정 상태
    var originCafeFilterInformation: CafeFilterInformation
    var cafeFilterInformation: CafeFilterInformation
    var mainViewState: CafeFilterBottomSheetViewState = .init(optionButtonCellViewStates: [])
    var containerViewHeight: CGFloat = .zero
    let headerViewHeight: CGFloat = 80
    let footerViewHeight: CGFloat = 84 + (UIApplication.keyWindow?.safeAreaInsets.bottom ?? 0.0)

    init(filterType: CafeFilter.MenuType, cafeFilterInformation: CafeFilterInformation) {
      self.filterType = filterType
      self.originCafeFilterInformation = cafeFilterInformation
      self.cafeFilterInformation = cafeFilterInformation
      updateMainViewState()
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case presentBottomSheet
    case hideBottomSheet
    case optionButtonTapped(optionType: CafeFilter.OptionType)
    case infoGuideButtonTapped
    case presentBubbleMessageView(BubbleMessage.State)
    case updateMainViewState
    case resetCafeFilterButtonTapped
    case resetCafeFilter
    case saveCafeFilterButtonTapped
    case updateContainerView(height: CGFloat)
    case bubbleMessageAction(BubbleMessage.Action)
    case delegate(Delegate)
  }

  enum Delegate: Equatable {
    case saveCafeFilter(information: CafeFilterInformation)
    case dismiss
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeFilterBottomSheet> {
    BindingReducer()

    Reduce { state, action in
      switch action {
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
        guard let guideType = state.guideType
        else { return .none }

        return EffectTask(
          value: .presentBubbleMessageView(
            .init(guideType: guideType)
          )
        )

      case .presentBubbleMessageView(let viewState):
        state.bubbleMessageViewState = viewState
        return .none

      case .updateMainViewState:
        state.updateMainViewState()
        return .none

      case .resetCafeFilterButtonTapped:
        return EffectTask(value: .resetCafeFilter)

      case .resetCafeFilter:
        switch state.filterType {
        case .detail:
          state.cafeFilterInformation.resetFilterInformation()
        case .outlet:
          state.cafeFilterInformation.outletOptionSet.removeAll()
        case .personnel:
          state.cafeFilterInformation.personnelOptionSet.removeAll()
        case .spaceSize:
          state.cafeFilterInformation.spaceSizeOptionSet.removeAll()
        case .runningTime:
          state.cafeFilterInformation.runningTimeOptionSet.removeAll()
        }
        return .concatenate(
          EffectTask(value: .delegate(.saveCafeFilter(information: state.cafeFilterInformation))),
          EffectTask(value: .delegate(.dismiss))
        )

      case .saveCafeFilterButtonTapped:
        return .concatenate(
          EffectTask(value: .delegate(.saveCafeFilter(information: state.cafeFilterInformation))),
          EffectTask(value: .delegate(.dismiss))
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

// MARK: - Mutating Function

extension CafeFilterBottomSheet.State {
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
}

// MARK: - Getter

extension CafeFilterBottomSheet.State {
  var scrollViewHeight: CGFloat {
    switch filterType {
    case .detail:
      return 435
    default:
      return 76
    }
  }

  var runningTimeOptionButtonCellViewState: CafeFilterOptionButtonCellViewState {
    .init(
      viewStates: CafeFilter.RunningTimeOption.allCases.map {
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
      viewStates: CafeFilter.OutletOption.allCases.map {
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
      viewStates: CafeFilter.SpaceSizeOption.allCases.map {
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
      viewStates: CafeFilter.PersonnelOption.allCases.map {
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
      viewStates: CafeFilter.FoodOption.allCases.map {
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
      viewStates: CafeFilter.ToiletOption.allCases.map {
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
      viewStates: CafeFilter.DrinkOption.allCases.map {
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
