//
//  CafeApp.swift
//  Cafe
//
//  Created by Min Min on 2023/05/06.
//

import SwiftUI
import ComposableArchitecture
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

@main
struct CafeApp: App {
  @UIApplicationDelegateAdaptor var delegate: AppDelegate

  init() {
    setUpKakaoLogin()
  }

  var body: some Scene {
    WindowGroup {
      AppCoordinatorView(
        store: .init(
          initialState: .initialState,
          reducer: AppCoordinator()
        )
      )
      .onOpenURL { url in
        if AuthApi.isKakaoTalkLoginUrl(url) {
          _ = AuthController.handleOpenUrl(url: url)
        }
      }
    }
  }

  private func setUpKakaoLogin() {
    guard let kakaoNativeAppKey = CofficeResources.bundle
      .object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else { return }
    KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
  }
}
