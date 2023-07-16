//
//  CafeFilterMenusCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/08.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeFilterMenus: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init(filterInformation: .initialState)
    static let mock: State = .init(filterInformation: .mock)

    @BindingState var cafeFilterBottomSheetState: CafeFilterBottomSheet.State?
    var buttonViewStates: [ButtonViewState] = []
    var filterInformation: CafeFilterInformation

    init(filterInformation: CafeFilterInformation) {
      self.filterInformation = filterInformation
      updateButtonViewStates()
    }

    mutating func updateButtonViewStates() {
      buttonViewStates = CafeFilter.MenuType.allCases
        .map { menuType in
          ButtonViewState(
            menuType: menuType,
            isFilterSetting: isFilterSetting(at: menuType)
          )
        }
    }

    func isFilterSetting(at menuType: CafeFilter.MenuType) -> Bool {
      switch menuType {
      case .detail:
        return filterInformation.outletOptionSet.isNotEmpty
          || filterInformation.runningTimeOptionSet.isNotEmpty
          || filterInformation.spaceSizeOptionSet.isNotEmpty
          || filterInformation.personnelOptionSet.isNotEmpty
          || filterInformation.foodOptionSet.isNotEmpty
          || filterInformation.toiletOptionSet.isNotEmpty
          || filterInformation.drinkOptionSet.isNotEmpty

      case .runningTime:
        return filterInformation.runningTimeOptionSet.isNotEmpty

      case .outlet:
        return filterInformation.outletOptionSet.isNotEmpty

      case .spaceSize:
        return filterInformation.spaceSizeOptionSet.isNotEmpty

      case .personnel:
        return filterInformation.personnelOptionSet.isNotEmpty
      }
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case filterButtonTapped(CafeFilter.MenuType)
    case presentFilterBottomSheetView(CafeFilterBottomSheet.State)
    case cafeFilterBottomSheetViewAction(CafeFilterBottomSheet.Action)
    case updateCafeFilter(information: CafeFilterInformation)
    case updateButtonViewStates
  }

  var body: some ReducerProtocolOf<CafeFilterMenus> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .filterButtonTapped(let menuType):
        guard let buttonViewStateIndex = state.buttonViewStates.firstIndex(where: { $0.menuType == menuType })
        else { return .none }

        state.buttonViewStates[buttonViewStateIndex].focusButton()
        return EffectTask(
          value: .presentFilterBottomSheetView(
            .init(filterType: menuType, cafeFilterInformation: state.filterInformation)
          )
        )

      case .presentFilterBottomSheetView(let viewState):
        state.cafeFilterBottomSheetState = viewState
        return .none

      case .updateCafeFilter(let information):
        state.filterInformation = information
        return EffectTask(value: .updateButtonViewStates)

      case .updateButtonViewStates:
        state.updateButtonViewStates()
        return .none

      case .cafeFilterBottomSheetViewAction(let action):
        switch action {
        case .saveCafeFilter(let information):
          state.cafeFilterBottomSheetState = nil
          return EffectTask(value: .updateCafeFilter(information: information))
        case .dismiss:
          state.cafeFilterBottomSheetState = nil
          return .none
        default:
          return .none
        }

      default:
        return .none
      }
    }
    .ifLet(
      \.cafeFilterBottomSheetState,
      action: /Action.cafeFilterBottomSheetViewAction
    ) {
      CafeFilterBottomSheet()
    }
  }
}

extension CafeFilterMenus.State {
  struct ButtonViewState: Equatable, Identifiable {
    let id = UUID()
    let menuType: CafeFilter.MenuType
    let isFilterSetting: Bool
    /// 버튼 메뉴 타입에 맞는 필터 설정 시 활성화 되는 상태
    private(set) var isFocused: Bool

    init(
      menuType: CafeFilter.MenuType,
      isFilterSetting: Bool,
      isFocused: Bool = false
    ) {
      self.menuType = menuType
      self.isFilterSetting = isFilterSetting
      self.isFocused = isFocused
    }

    mutating func focusButton() {
      isFocused = true
    }

    var foregroundColorAsset: CofficeColors {
      switch menuType {
      case .detail:
        return isFilterSetting
        ? CofficeAsset.Colors.grayScale9
        : CofficeAsset.Colors.grayScale7
      default:
        return isFilterSetting
        ? CofficeAsset.Colors.grayScale1
        : CofficeAsset.Colors.grayScale7
      }
    }

    var backgroundColorAsset: CofficeColors {
      switch menuType {
      case .detail:
        return CofficeAsset.Colors.grayScale1
      default:
        return isFilterSetting
        ? CofficeAsset.Colors.grayScale9
        : CofficeAsset.Colors.grayScale1
      }
    }

    var borderColorAsset: CofficeColors {
      switch menuType {
      case .detail:
        if isFocused {
          return CofficeAsset.Colors.grayScale9
        } else {
          return isFilterSetting
          ? CofficeAsset.Colors.grayScale9
          : CofficeAsset.Colors.grayScale4
        }
      default:
        if isFocused {
          return CofficeAsset.Colors.grayScale9
        } else {
          return isFilterSetting
          ? CofficeAsset.Colors.grayScale9
          : CofficeAsset.Colors.grayScale4
        }
      }
    }
  }
}
