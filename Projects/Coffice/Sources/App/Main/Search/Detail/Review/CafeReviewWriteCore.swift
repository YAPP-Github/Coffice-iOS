//
//  CafeReviewWriteCore.swift
//  coffice
//
//  Created by Min Min on 2023/06/29.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct CafeReviewWrite: ReducerProtocol {
  typealias OutletStateOption = CafeReviewOptionButtons.State.OutletOption
  typealias WifiStateOption = CafeReviewOptionButtons.State.WifiOption
  typealias NoiseOption = CafeReviewOptionButtons.State.NoiseOption

  struct State: Equatable {
    static let mock: Self = .init(
      optionButtonStates: [
        .init(optionType: .outletState(nil)),
        .init(optionType: .wifiState(nil)),
        .init(optionType: .noise(nil))
      ]
    )

    var optionButtonStates: [CafeReviewOptionButtons.State]
    var isSaveButtonEnabled = false

    var saveButtonBackgroundColorAsset: CofficeColors {
      return isSaveButtonEnabled ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale6
    }
  }

  enum Action: Equatable {
    case onAppear
    case dismissView
    case optionButtonsAction(CafeReviewOptionButtons.Action)
    case updateSaveButtonState
  }

  var body: some ReducerProtocolOf<CafeReviewWrite> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .optionButtonsAction(.optionButtonTapped(let optionType, let index)):
        switch optionType {
        case .outletState:
          state.optionButtonStates[optionType.index].optionType = .outletState(OutletStateOption.allCases[index])
        case .wifiState:
          state.optionButtonStates[optionType.index].optionType = .wifiState(WifiStateOption.allCases[index])
        case .noise:
          state.optionButtonStates[optionType.index].optionType = .noise(NoiseOption.allCases[index])
        }

        state.optionButtonStates[optionType.index].updateOptionButtons()
        debugPrint("tapped optionButtonState : \(state.optionButtonStates[optionType.index]) at \(index)")
        return EffectTask(value: .updateSaveButtonState)

      case .updateSaveButtonState:
        state.isSaveButtonEnabled = state.optionButtonStates.allSatisfy { $0.isSelectedOptionButton }
        return .none

      default:
        return .none
      }
    }
  }
}
