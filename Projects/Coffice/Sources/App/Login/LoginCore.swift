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
import Network

struct Login: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()
    var appleLoginToken: String?

    var isOnboarding: Bool {
      UserDefaults.standard.bool(forKey: "alreadyLaunched").isFalse
      && CoreNetwork.shared.token == nil
    }

    @BindingState var loginServiceTermsBottomSheetState: LoginServiceTermsBottomSheet.State?
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case lookAroundButtonTapped
    case kakaoLoginButtonTapped
    case appleLoginButtonTapped(token: String)
    case loginAppleAccount
    case loginKakaoAccount
    case loginCompleted
    case loginServiceTermsBottomSheetAction(LoginServiceTermsBottomSheet.Action)
    case presentLoginServiceTermsBottomSheet
  }

  @Dependency(\.accountClient) private var accountClient

  var body: some ReducerProtocolOf<Login> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .kakaoLoginButtonTapped:
        return EffectTask(value: .presentLoginServiceTermsBottomSheet)

      case .loginKakaoAccount:
        return .run { send in
          let accessToken = try await fetchKakaoOAuthToken()
          _ = try await accountClient.login(loginType: .kakao, accessToken: accessToken)
          await send(.loginCompleted)
        } catch: { error, send in
          debugPrint(error)
        }

      case .appleLoginButtonTapped(let token):
        state.appleLoginToken = token
        return EffectTask(value: .presentLoginServiceTermsBottomSheet)

      case .loginAppleAccount:
        guard let appleloginToken = state.appleLoginToken
        else { return .none }

        return .run { send in
          _ = try await accountClient.login(loginType: .apple, accessToken: appleloginToken)
          await send(.loginCompleted)
        } catch: { error, send in
          debugPrint(error)
        }

      case .lookAroundButtonTapped:
        return .run { send in
          let response = try await accountClient.login(loginType: .anonymous,
                                                     accessToken: nil)
          KeychainManager.shared.deleteUserToken()
          KeychainManager.shared.addItem(key: "anonymousToken",
                                         value: response.accessToken)
          await send(.loginCompleted)
        } catch: { error, send in
          debugPrint(error)
        }

      case .presentLoginServiceTermsBottomSheet:
        state.loginServiceTermsBottomSheetState = .initialState
        return .none

      default:
        return .none
      }
    }

    // MARK: Login Service Terms Bottom Sheet
    Reduce { state, action in
      switch action {
      case .loginServiceTermsBottomSheetAction(let action):
        switch action {
        case .dismissView:
          state.loginServiceTermsBottomSheetState = nil
        default:
          return .none
        }
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.loginServiceTermsBottomSheetState,
      action: /Action.loginServiceTermsBottomSheetAction
    ) {
      LoginServiceTermsBottomSheet()
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
