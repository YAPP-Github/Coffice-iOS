//
//  LoginServiceTermsBottomSheetCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/20.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct LoginServiceTermsBottomSheet: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()
    @BindingState var webViewState: CommonWebReducer.State?

    var termsOptionButtonViewStates: [TermsOptionButtonViewState] = TermsType.allCases
      .map({ TermsOptionButtonViewState(type: $0, isSelected: false) }) {
        didSet {
          isWholeTermsAgreed = termsOptionButtonViewStates.allSatisfy(\.isSelected)
        }
      }
    var isWholeTermsAgreed = false
    var selectedOptionButtonViewState: TermsOptionButtonViewState?
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case wholeTermsAgreementButtonTapped
    case termsOptionButtonTapped(viewState: TermsOptionButtonViewState)
    case termsWebMenuButtonTapped(viewState: TermsOptionButtonViewState)
    case delegate(Delegate)
    case commonWebReducerAction(CommonWebReducer.Action)
    case webViewAction(CommonWebReducer.Action)
    case dismissWebView
  }

  enum Delegate: Equatable {
    case confirmButtonTapped
    case dismissView
  }

  var body: some ReducerProtocolOf<LoginServiceTermsBottomSheet> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .wholeTermsAgreementButtonTapped:
        state.isWholeTermsAgreed.toggle()
        let isWholeTermsAgreed = state.isWholeTermsAgreed
        state.termsOptionButtonViewStates = TermsType.allCases
          .map { TermsOptionButtonViewState(type: $0, isSelected: isWholeTermsAgreed) }
        return .none

      case .termsOptionButtonTapped(let viewState):
        state.termsOptionButtonViewStates[viewState.index].isSelected.toggle()
        return .none

      case .termsWebMenuButtonTapped(let viewState):
        state.selectedOptionButtonViewState = viewState
        state.webViewState = .init(urlString: viewState.type.urlString)
        return .none

      case .dismissWebView:
        state.webViewState = nil
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.webViewState,
      action: /Action.commonWebReducerAction
    ) {
      CommonWebReducer()
    }
  }
}

// MARK: - Sub Models

extension LoginServiceTermsBottomSheet {
  enum TermsType: Int, CaseIterable {
    case appService
    case locationService
    case privacyPolicy

    var urlString: String {
      switch self {
      case .appService:
        return "https://traveling-jade-4ad.notion.site/0b8d9c87d5be459c97860ddb4bffaa31"
      case .locationService:
        return "https://traveling-jade-4ad.notion.site/f946b1a337704f108f11d3c6333569d8"
      case .privacyPolicy:
        return "https://traveling-jade-4ad.notion.site/74a66cfd0dc34c17b0f2f8da4f1cd1bb"
      }
    }
  }

  struct TermsOptionButtonViewState: Equatable, Identifiable {
    let id = UUID()
    let type: TermsType
    var isSelected: Bool

    var title: String {
      switch type {
      case .appService:
        return "서비스 이용약관"
      case .locationService:
        return "위치기반 서비스 이용약관"
      case .privacyPolicy:
        return "개인정보 처리방침"
      }
    }

    var index: Int {
      return type.rawValue
    }

    var checkboxImage: CofficeImages {
      isSelected
      ? CofficeAsset.Asset.checkboxCircleFill24px
      : CofficeAsset.Asset.checkboxCircleLine24px
    }

    var checkboxImageColor: CofficeColors {
      isSelected
      ? CofficeAsset.Colors.grayScale9
      : CofficeAsset.Colors.grayScale4
    }
  }
}

// MARK: - Getters

extension LoginServiceTermsBottomSheet.State {
  var wholeTermsAgreementCheckboxImage: CofficeImages {
    isWholeTermsAgreed
    ? CofficeAsset.Asset.checkboxCircleFill24px
    : CofficeAsset.Asset.checkboxCircleLine24px
  }

  var wholeTermsAgreementCheckboxColor: CofficeColors {
    isWholeTermsAgreed
    ? CofficeAsset.Colors.grayScale9
    : CofficeAsset.Colors.grayScale4
  }

  var confirmButtonBackgroundColor: CofficeColors {
    isWholeTermsAgreed
    ? CofficeAsset.Colors.grayScale9
    : CofficeAsset.Colors.grayScale5
  }

  var webViewTitle: String {
    return selectedOptionButtonViewState?.title ?? "-"
  }
}
