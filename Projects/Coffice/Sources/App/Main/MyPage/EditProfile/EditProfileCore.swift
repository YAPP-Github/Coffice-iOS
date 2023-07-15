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
  enum NicknameValidationType {
    case empty
    case tooLong
    case tooShort
    case invalidCharacter
    case duplicated
    case valid
    case none

    var description: String {
      switch self {
      case .empty, .tooLong, .tooShort, .invalidCharacter:
        return "한글/영어/숫자 최소 2자, 최대15자로 입력해주세요."
      case .duplicated:
        return "이미 존재하는 닉네임입니다."
      case .valid, .none:
        return ""
      }
    }
  }
  struct State: Equatable {
    static let initialState: State = .init(nickname: "기존닉네임")

    let oldNickname: String
    let title = "프로필 수정"
    var nicknameValidationType: NicknameValidationType = .valid
    @BindingState var nicknameTextField: String
    var isNicknameValid: Bool {
      return oldNickname != nicknameTextField && nicknameTextField.isNotEmpty
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
        // TODO: 서버 요청 결과에 따라, validationType 수정[entity 내부에서 enum관리], test: duplicated
        state.nicknameValidationType = .duplicated
        return .none
        // TODO: 서버 나오면 기능 연결 (닉네임 수정 확인)
        // return EffectTask(value: .popView)

      case .clearText:
        state.nicknameTextField.removeAll()
        return .none

      default:
        return .none
      }
    }
  }
}
