//
//  CommonBottomSheet.swift
//  coffice
//
//  Created by 천수현 on 2023/07/08.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CommonBottomSheet: ReducerProtocol {
  struct State: Equatable {
    static var mock: Self {
      .init(
        title: "제목",
        description: "내용",
        cancelButtonTitle: "취소",
        confirmButtonTitle: "확인"
      )
    }

    var isBottomSheetPresented = true
    let dismissAnimationDuration: Double = 0.3
    let dismissDelayNanoseconds: UInt64 = 300_000_000
    var containerViewHeight: CGFloat = .zero
    let headerViewHeight: CGFloat = 80
    let footerViewHeight: CGFloat = 84 + (UIApplication.keyWindow?.safeAreaInsets.bottom ?? 0.0)
    var title: String
    var description: String
    var cancelButtonTitle: String
    var confirmButtonTitle: String

    init(title: String, description: String, cancelButtonTitle: String, confirmButtonTitle: String) {
      self.title = title
      self.description = description
      self.cancelButtonTitle = cancelButtonTitle
      self.confirmButtonTitle = confirmButtonTitle
    }
  }

  enum Action: Equatable {
    case dismiss
    /// dismiss 애니메이션 적용을 위해 딜레이 시간을 적용한 이벤트
    case dismissWithDelay
    case presentBottomSheet
    case hideBottomSheet
    case backgroundViewTapped
    case cancelButtonTapped
    case confirmButtonTapped
  }

  var body: some ReducerProtocolOf<CommonBottomSheet> {
    Reduce { state, action in
      switch action {
      case .backgroundViewTapped:
        return EffectTask(value: .dismissWithDelay)

      case .hideBottomSheet:
        state.isBottomSheetPresented = false
        return .none

      case .presentBottomSheet:
        state.isBottomSheetPresented = true
        return .none

      case .dismissWithDelay:
        let dismissDelayNanoseconds = Int(state.dismissDelayNanoseconds)
        state.isBottomSheetPresented = false
        return .concatenate(
          EffectTask(value: .hideBottomSheet)
            .delay(for: .nanoseconds(dismissDelayNanoseconds), scheduler: DispatchQueue.main)
            .eraseToEffect(),
          EffectTask(value: .dismiss)
        )

      default:
        return .none
      }
    }
  }
}
