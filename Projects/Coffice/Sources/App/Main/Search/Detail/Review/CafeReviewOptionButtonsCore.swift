//
//  CafeReviewOptionButtonsCore.swift
//  coffice
//
//  Created by Min Min on 2023/06/30.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeReviewOptionButtons: ReducerProtocol {
  struct State: Equatable, Identifiable {
    static let mock: State = .init(optionType: .outletState(.enough))

    let id = UUID()
    var optionButtonViewStates: [OptionButtonViewState] = []
    var optionType: ReviewOption {
      didSet {
        updateOptionButtons()
      }
    }
    var isSelectedOptionButton: Bool {
      return optionButtonViewStates.contains(where: \.isSelected)
    }

    var title: String {
      switch optionType {
      case .outletState:
        return "콘센트  🔌"
      case .wifiState:
        return "와이파이  📶"
      case .noise:
        return "소음  🔊"
      }
    }

    init(optionType: ReviewOption) {
      self.optionType = optionType
      updateOptionButtons()
    }

    mutating func updateOptionButtons() {
      switch optionType {
      case .outletState(let option):
        optionButtonViewStates = ReviewOption.OutletOption.allCases
          .map {
            OptionButtonViewState(
              title: $0.title,
              optionType: ReviewOption.outletState(option == $0 ? $0 : nil)
            )
          }
      case .wifiState(let option):
        optionButtonViewStates = ReviewOption.WifiOption.allCases
          .map {
            OptionButtonViewState(
              title: $0.title,
              optionType: ReviewOption.wifiState(option == $0 ? $0 : nil)
            )
          }
      case .noise(let option):
        optionButtonViewStates = ReviewOption.NoiseOption.allCases
          .map {
            OptionButtonViewState(
              title: $0.title,
              optionType: ReviewOption.noise(option == $0 ? $0 : nil)
            )
          }
      }
    }
  }

  enum Action: Equatable {
    case onAppear
    case optionButtonTapped(optionType: ReviewOption, index: Int)
  }

  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .optionButtonTapped:
        // CafeReviewWrite Reducer에서 이벤트 처리
        return .none
      }
    }
  }
}

// MARK: - Sub Option Models

extension CafeReviewOptionButtons.State {
  struct OptionButtonViewState: Equatable, Identifiable {
    let id = UUID()
    let title: String
    var optionType: ReviewOption

    var isSelected: Bool {
      switch optionType {
      case .outletState(let option):
        return option != nil
      case .wifiState(let option):
        return option != nil
      case .noise(let option):
        return option != nil
      }
    }

    var textColorAsset: CofficeColors {
      if isSelected {
        return CofficeAsset.Colors.grayScale1
      } else {
        return CofficeAsset.Colors.grayScale7
      }
    }

    var backgroundColorAsset: CofficeColors {
      if isSelected {
        return CofficeAsset.Colors.grayScale9
      } else {
        return CofficeAsset.Colors.grayScale1
      }
    }

    var borderColorAsset: CofficeColors {
      if isSelected {
        return CofficeAsset.Colors.grayScale9
      } else {
        return CofficeAsset.Colors.grayScale4
      }
    }
  }
}

enum ReviewOption: Equatable {
  case outletState(OutletOption?)
  case wifiState(WifiOption?)
  case noise(NoiseOption?)

  var index: Int {
    switch self {
    case .outletState:
      return 0
    case .wifiState:
      return 1
    case .noise:
      return 2
    }
  }

  enum OutletOption: Equatable, CaseIterable {
    case few
    case some
    case enough

    var title: String {
      switch self {
      case .few:
        return "거의 없어요"
      case .some:
        return "적당해요"
      case .enough:
        return "넉넉해요 👍"
      }
    }

    var dtoName: String {
      switch self {
      case .few:
        return "FEW"
      case .some:
        return "SEVERAL"
      case .enough:
        return "MANY"
      }
    }
  }

  enum WifiOption: Equatable, CaseIterable {
    case slow
    case fast

    var title: String {
      switch self {
      case .slow:
        return "아쉬워요"
      case .fast:
        return "빨라요 👍"
      }
    }

    var dtoName: String {
      switch self {
      case .slow:
        return "SLOW"
      case .fast:
        return "FAST"
      }
    }
  }

  enum NoiseOption: Equatable, CaseIterable {
    case loud
    case normal
    case quiet

    var title: String {
      switch self {
      case .loud:
        return "시끄러워요"
      case .normal:
        return "보통이에요"
      case .quiet:
        return "조용해요 👍"
      }
    }

    var dtoName: String {
      switch self {
      case .loud:
        return "NOISY"
      case .normal:
        return "NORMAL"
      case .quiet:
        return "QUIET"
      }
    }
  }
}
