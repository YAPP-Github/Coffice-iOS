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
  // TODO: ex) 서버 응답 결과에 따라, empty, tooLong, 등등..
  enum NicknameValidationType: Equatable {
    case checked(response: CheckNicknameResponse)
    case unchecked
  }

  struct State: Equatable {
    static let initialState: State = .init(nickname: "기존닉네임")

    let oldNickname: String
    let navigationTitle = "프로필 편집"
    var nicknameValidationType: NicknameValidationType = .unchecked
    @BindingState var nicknameTextField: String
    var isAbleToCheckNickname: Bool {
      return oldNickname != nicknameTextField
      && nicknameTextField.isNotEmpty
    }

    init(nickname: String) {
      oldNickname = nickname
      nicknameTextField = oldNickname
    }
  }

  enum Action: Equatable, BindableAction {
    case onAppear
    case popView
    case dismissButtonTapped
    case binding(BindingAction<State>)
    case confirmButtonTapped
    case checkNicknameResponse(response: CheckNicknameResponse)
    case clearText
    case showTabBar
    case hideTabBar
  }

  @Dependency(\.checkNicknameAPIClient) private var checkNicknameClient

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
        return .run { [nickname = state.nicknameTextField] send in
          let response = try await checkNicknameClient.checkNickname(nickName: nickname)
          await send(.checkNicknameResponse(response: response))
        }

      case .clearText:
        state.nicknameTextField.removeAll()
        return .none

      case .checkNicknameResponse(let response):
        state.nicknameValidationType = .checked(response: response)
        if state.nicknameValidationType == .checked(response: .valid) {
          return .concatenate(
            EffectTask(value: .showTabBar),
            EffectTask(value: .popView)
          )
        }
        return .none

      default:
        return .none
      }
    }
  }
}
