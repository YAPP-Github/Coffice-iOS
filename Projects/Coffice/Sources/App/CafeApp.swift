//
//  CafeApp.swift
//  Cafe
//
//  Created by Min Min on 2023/05/06.
//

import ComposableArchitecture
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import SwiftUI

@main
struct CafeApp: App {
  @UIApplicationDelegateAdaptor var delegate: AppDelegate

  init() {
    setupKakaoLogin()
  }

  var body: some Scene {
    WindowGroup {
      AppCoordinatorView(
        store: .init(
          initialState: .init(),
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

  private func setupKakaoLogin() {
    guard let kakaoNativeAppKey = CofficeResources.bundle
      .object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else { return }
    KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
  }
}
