//
//  LoginCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import FirebaseAnalytics
import KakaoSDKAuth
import KakaoSDKUser

struct Login: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()

    let title = "Login"
  }

  enum Action: Equatable {
    case onAppear
    case useAppAsNonMember
    case kakaoLoginButtonClicked
    case appleLoginButtonClicked
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<Login> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none

      case .kakaoLoginButtonClicked:
        if UserApi.isKakaoTalkLoginAvailable() {
          UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
            if let error = error {
              debugPrint(error)
            } else {
              guard let accessToken = oauthToken?.accessToken else { return }
//              self.requestLogin(oauthType: .kakao, requestValue: accessToken)
            }
          }
        } else {
          UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
              debugPrint(error)
            } else {
              guard let accessToken = oauthToken?.accessToken else { return }
//              self.requestLogin(oauthType: .kakao, requestValue: accessToken)
            }
          }
        }
        return .none

      case .appleLoginButtonClicked:
        debugPrint("apple login")
        return .none

      case .useAppAsNonMember:
        // TODO: GALogger 구현 필요
        let event = "didTapUseAppAsNonMemberButton"
        let parameters = [
          "file": #file,
          "function": #function
        ]

        Analytics.setUserID("userID = \(1234)")
        Analytics.setUserProperty("ko", forName: "country")
        Analytics.logEvent(AnalyticsEventSelectItem, parameters: nil)
        Analytics.logEvent(event, parameters: parameters)
        return .none
      }
    }
  }
}
