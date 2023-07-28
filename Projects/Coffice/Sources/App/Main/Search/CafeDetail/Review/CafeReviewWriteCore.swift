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
    @BindingState var reviewText: String?
    @BindingState var dismissConfirmBottomSheetState: BottomSheetReducer.State?
    var deleteConfirmBottomSheetType: BottomSheetType = .dismissConfirm
    var optionButtonStates: [CafeReviewOptionButtons.State]
    var reviewType: ReviewType
    let placeId: Int
    let imageUrl: URL?
    let cafeName: String
    let cafeAddress: String
    let reviewId: Int?

    var isSaveButtonEnabled = false
    var isDismissConfirmed = false
    let textViewDidBeginEditingScrollId = UUID()
    let textViewDidEndEditingScrollId = UUID()
    let maximumTextLength = 200

    var textViewBottomPadding: CGFloat = 0.0
    var currentTextLengthDescription: String { "\(reviewText?.count ?? 0)" }
    var maximumTextLengthDescription: String { "/\(maximumTextLength)" }
    var shouldPresentTextViewPlaceholder: Bool {
      reviewText?.isEmpty == true
    }
    var saveButtonTitle: String {
      return reviewType == .create ? "등록하기" : "수정하기"
    }
    var saveButtonBackgroundColorAsset: CofficeColors {
      return isSaveButtonEnabled ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale6
    }

    init(
      reviewType: ReviewType,
      placeId: Int,
      imageUrlString: String? = nil,
      reviewId: Int? = nil,
      cafeName: String? = nil,
      cafeAddress: String? = nil,
      outletOption: OutletStateOption? = nil,
      wifiOption: WifiStateOption? = nil,
      noiseOption: NoiseOption? = nil,
      reviewText: String? = nil
    ) {
      self.reviewType = reviewType
      self.placeId = placeId
      self.imageUrl = URL(string: imageUrlString ?? "")
      self.reviewId = reviewId
      self.cafeName = cafeName ?? "-"
      self.cafeAddress = cafeAddress ?? "-"

      switch reviewType {
      case .create:
        optionButtonStates = [
          .init(optionType: .outletState(nil)),
          .init(optionType: .wifiState(nil)),
          .init(optionType: .noise(nil))
        ]
      case .edit:
        optionButtonStates = [
          .init(optionType: .outletState(outletOption)),
          .init(optionType: .wifiState(wifiOption)),
          .init(optionType: .noise(noiseOption))
        ]
        self.reviewText = reviewText
        isSaveButtonEnabled = true
      }
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case dismissView
    case dismissViewWithDelay
    case optionButtonsAction(CafeReviewOptionButtons.Action)
    case dismissConfirmBottomSheet(action: BottomSheetReducer.Action)
    case presentDeleteConfirmBottomSheet
    case dismissDeleteConfirmBottomSheet
    case dismissConfirmBottomSheetDismissed
    case updateSaveButtonState
    case updateTextViewBottomPadding(isTextViewEditing: Bool)
    case saveButtonTapped
    case uploadReview
    case uploadReviewResponse(TaskResult<HTTPURLResponse>)
    case editReviewResponse(TaskResult<HTTPURLResponse>)
  }

  @Dependency(\.reviewAPIClient) private var reviewAPIClient

  var body: some ReducerProtocolOf<CafeReviewWrite> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .dismissViewWithDelay:
        return EffectTask(value: .dismissView)
          .delay(for: 0.1, scheduler: DispatchQueue.main)
          .eraseToEffect()

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

        switch state.reviewType {
        case .create:
          let requestValue = ReviewUploadRequestValue(
            placeId: state.placeId,
            electricOutletOption: electricOutletLevel,
            wifiOption: wifiLevel,
            noiseOption: noiseLevel,
            content: state.reviewText
          )
          return .run { send in
            let response = try await reviewAPIClient.uploadReview(requestValue: requestValue)
            await send(.uploadReviewResponse(.success(response)))
          } catch: { error, send in
            await send(.uploadReviewResponse(.failure(error)))
          }
        case .edit:
          guard let reviewId = state.reviewId else { return .none }
          let requestValue = ReviewEditRequestValue(
            placeId: state.placeId,
            reviewId: reviewId,
            electricOutletOption: electricOutletLevel,
            wifiOption: wifiLevel,
            noiseOption: noiseLevel,
            content: state.reviewText
          )
          return .run { send in
            let response = try await reviewAPIClient.editReview(requestValue: requestValue)
            await send(.editReviewResponse(.success(response)))
          } catch: { error, send in
            await send(.editReviewResponse(.failure(error)))
          }
        }

      case .uploadReviewResponse(let result):
        switch result {
        case .success:
          return EffectTask(value: .dismissView)
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .editReviewResponse(let result):
        switch result {
        case .success:
          return EffectTask(value: .dismissView)
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .dismissConfirmBottomSheet(let action):
        switch action {
        case .confirmButtonTapped:
          return EffectTask(value: .dismissDeleteConfirmBottomSheet)
        case .cancelButtonTapped:
          state.isDismissConfirmed = true
          return EffectTask(value: .dismissDeleteConfirmBottomSheet)
        }

      case .presentDeleteConfirmBottomSheet:
        state.dismissConfirmBottomSheetState = .init()
        return .none

      case .dismissDeleteConfirmBottomSheet:
        state.dismissConfirmBottomSheetState = nil
        return .none

      case .dismissConfirmBottomSheetDismissed:
        if state.isDismissConfirmed {
          return EffectTask(value: .dismissViewWithDelay)
        }
        return .none

      default:
        return .none
      }
    }
  }
}

extension CafeReviewWrite {
  enum BottomSheetType {
    case dismissConfirm

    var content: BottomSheetContent {
      switch self {
      case .dismissConfirm:
        return .init(
          title: "정말로 나가실 건가요?",
          description: "입력하신 내용이 사라져요!",
          confirmButtonTitle: "계속 진행하기",
          cancelButtonTitle: "나가기"
        )
      }
    }
  }
}
