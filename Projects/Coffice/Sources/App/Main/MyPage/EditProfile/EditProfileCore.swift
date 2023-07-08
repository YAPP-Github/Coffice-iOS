//
//  EditProfileCore.swift
//  coffice
//
//  Created by 천수현 on 2023/07/07.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct EditProfile: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()

    let title = "프로필 수정"
    @BindingState var nicknameTextField = "기존닉네임"
    var isNicknameValid = false
  }

  enum Action: Equatable, BindableAction {
    case onAppear
    case popView
    case dismissButtonTapped
    case binding(BindingAction<State>)
    case confirmButtonTapped
    case clearText
    case showTabBar
    case hideTabBar
  }

  var body: some ReducerProtocolOf<EditProfile> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .dismissButtonTapped:
        return .concatenate(
          EffectTask(value: .showTabBar),
          EffectTask(value: .popView)
        )

      case .binding(\.$nicknameTextField):
        return .none

      case .confirmButtonTapped:
        return .none

      case .clearText:
        state.nicknameTextField.removeAll()
        return .none

      default:
        return .none
      }
    }
  }
}
