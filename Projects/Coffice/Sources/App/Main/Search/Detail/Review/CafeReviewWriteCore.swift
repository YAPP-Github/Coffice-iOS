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
  enum ReviewType {
    case create
    case edit
  }

  typealias OutletStateOption = ReviewOption.OutletOption
  typealias WifiStateOption = ReviewOption.WifiOption
  typealias NoiseOption = ReviewOption.NoiseOption

  struct State: Equatable, Identifiable {
    static let mock: Self = .init(reviewType: .create, placeId: 1)

    let id = UUID()
    var optionButtonStates: [CafeReviewOptionButtons.State]
    var reviewType: ReviewType
    let placeId: Int

    var isSaveButtonEnabled = false
    @BindingState var reviewText = ""
    let textViewDidBeginEditingScrollId = UUID()
    let textViewDidEndEditingScrollId = UUID()
    let maximumTextLength = 200

    var textViewBottomPadding: CGFloat = 0.0
    var currentTextLengthDescription: String { "\(reviewText.count)" }
    var maximumTextLengthDescription: String { "/\(maximumTextLength)" }
    var shouldPresentTextViewPlaceholder: Bool {
      reviewText.isEmpty
    }
    var saveButtonTitle: String {
      return reviewType == .create ? "등록하기" : "수정하기"
    }
    var saveButtonBackgroundColorAsset: CofficeColors {
      return isSaveButtonEnabled ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale6
    }

    init(reviewType: ReviewType, placeId: Int) {
      self.reviewType = reviewType
      self.placeId = placeId

      switch reviewType {
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
    case updateTextViewBottomPadding(isTextViewEditing: Bool)
    case saveButtonTapped
    case uploadReview
    case uploadReviewResponse(TaskResult<HTTPURLResponse>)
  }

  @Dependency(\.reviewAPIClient) private var reviewClient

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

      case .updateTextViewBottomPadding(let isTextViewEditing):
        state.textViewBottomPadding = isTextViewEditing ? 200 : 0
        return .none

      case .saveButtonTapped:
        return EffectTask(value: .uploadReview)

      case .uploadReview:
        var electricOutletLevel: OutletStateOption = .few
        var wifiLevel: WifiStateOption = .slow
        var noiseLevel: NoiseOption = .quiet

        state.optionButtonStates.forEach { buttonState in
          switch buttonState.optionType {
          case .outletState(let option):
            electricOutletLevel = option ?? .few
          case .wifiState(let option):
            wifiLevel = option ?? .slow
          case .noise(let option):
            noiseLevel = option ?? .quiet
          }
        }

        let requestValue = ReviewUploadRequestValue(
          placeId: state.placeId,
          electricOutletOption: electricOutletLevel,
          wifiOption: wifiLevel,
          noiseOption: noiseLevel,
          content: state.reviewText
        )

        return .run { send in
          let response = try await reviewClient.uploadReview(requestValue: requestValue)
          await send(.uploadReviewResponse(.success(response)))
        } catch: { error, send in
          await send(.uploadReviewResponse(.failure(error)))
        }

      case .uploadReviewResponse(let result):
        switch result {
        case .success:
          return EffectTask(value: .dismissView)
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      default:
        return .none
      }
    }
  }
}
