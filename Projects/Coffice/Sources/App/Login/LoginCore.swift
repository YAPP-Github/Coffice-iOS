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
    case appleLoginButtonClicked(token: String)
  }

  @Dependency(\.loginClient) private var loginClient

  var body: some ReducerProtocolOf<Login> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none

      case .kakaoLoginButtonClicked:
        return .run { send in
          let accessToken = try await fetchKakaoOAuthToken()
          let _ = try await loginClient.login(loginType: .kakao,
                                                     accessToken: accessToken)
        } catch: { error, send in
            debugPrint(error)
        }

      case .appleLoginButtonClicked(let token):
        return .run { send in
          let _ = try await loginClient.login(loginType: .apple,
                                                     accessToken: token)
        } catch: { error, send in
            debugPrint(error)
        }

      case .useAppAsNonMember:
        return .run { send in
          let _ = try await loginClient.login(loginType: .anonymous,
                                                     accessToken: nil)
        } catch: { error, send in
            debugPrint(error)
        }
      }
    }
  }

  private func fetchKakaoOAuthToken() async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      let loginCompletion: (OAuthToken?, Error?) -> Void = { (oauthToken, error) in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          guard let accessToken = oauthToken?.accessToken else {
            continuation.resume(throwing: LoginError.emptyAccessToken)
            return
          }
          continuation.resume(returning: accessToken)
        }
      }

      DispatchQueue.main.async {
        if UserApi.isKakaoTalkLoginAvailable() {
          UserApi.shared.loginWithKakaoTalk(completion: loginCompletion)
        } else {
          UserApi.shared.loginWithKakaoAccount(completion: loginCompletion)
        }
      }
    }
  }
}
