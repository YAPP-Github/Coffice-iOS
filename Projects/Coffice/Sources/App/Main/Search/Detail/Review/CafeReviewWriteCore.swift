//
//  CafeReviewWriteCore.swift
//  coffice
//
//  Created by Min Min on 2023/06/29.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeReviewWrite: ReducerProtocol {
  enum ReviewOption {
    case create
    case edit
  }

  typealias OutletStateOption = CafeReviewOptionButtons.State.OutletOption
  typealias WifiStateOption = CafeReviewOptionButtons.State.WifiOption
  typealias NoiseOption = CafeReviewOptionButtons.State.NoiseOption

  struct State: Equatable {
    static let mock: Self = .init(reviewOption: .create)

    var optionButtonStates: [CafeReviewOptionButtons.State]
    var reviewOption: ReviewOption

    var isSaveButtonEnabled = false
    @BindingState var reviewText = ""
    let textViewScrollId = UUID()
    let mainScrollViewScrollId = UUID()
    let maximumTextLength = 200

    var saveButtonBackgroundColorAsset: CofficeColors {
      return isSaveButtonEnabled ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale6
    }
    var currentTextLengthDescription: String { "\(reviewText.count)" }
    var maximumTextLengthDescription: String { "/\(maximumTextLength)" }
    var shouldPresentTextViewPlaceholder: Bool {
      reviewText.isEmpty
    }

    init(reviewOption: ReviewOption) {
      self.reviewOption = reviewOption

      switch reviewOption {
      case .create:
        optionButtonStates = [
          .init(optionType: .outletState(nil)),
          .init(optionType: .wifiState(nil)),
          .init(optionType: .noise(nil))
        ]
      case .edit:
        // TODO: 기존 리뷰 정보를 참고해서 버튼, 텍스트뷰 상태 업데이트 필요
        optionButtonStates = [
          .init(optionType: .outletState(nil)),
          .init(optionType: .wifiState(nil)),
          .init(optionType: .noise(nil))
        ]
        reviewText = ""
      }
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case dismissView
    case optionButtonsAction(CafeReviewOptionButtons.Action)
    case updateSaveButtonState
  }

  var body: some ReducerProtocolOf<CafeReviewWrite> {
    BindingReducer()

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
        state.isSaveButtonEnabled = state.optionButtonStates.allSatisfy(\.isSelectedOptionButton)
        return .none

      default:
        return .none
      }
    }
  }
}
