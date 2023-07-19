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
    var termsOptionButtonViewStates: [TermsOptionButtonViewState] = TermsType.allCases
      .map({ TermsOptionButtonViewState(type: $0, isSelected: false) }) {
        didSet {
          isWholeTermsAgreed = termsOptionButtonViewStates.allSatisfy(\.isSelected)
        }
      }
    var isWholeTermsAgreed = false
  }

  enum Action: Equatable {
    case onAppear
    case wholeTermsAgreementButtonTapped
    case termsOptionButtonTapped(viewState: TermsOptionButtonViewState)
    case termsWebMenuButtonTapped(termsType: TermsType)
    case delegate(Delegate)
  }

  enum Delegate: Equatable {
    case confirmButtonTapped
    case dismissView
  }

  var body: some ReducerProtocolOf<LoginServiceTermsBottomSheet> {
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

      case .termsWebMenuButtonTapped(let termsType):
        // TODO: 약관동의 웹뷰 표출 필요
        switch termsType {
        case .appService:
          return .none
        case .locationService:
          return .none
        case .privacyPolicy:
          return .none
        }

      default:
        return .none
      }
    }
  }
}

// MARK: - Sub Models

extension LoginServiceTermsBottomSheet {
  enum TermsType: Int, CaseIterable {
    case appService
    case locationService
    case privacyPolicy
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
}
