//
//  AppDelegate.swift
//  Cafe
//
//  Created by Min Min on 2023/06/03.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Firebase
import KakaoSDKAuth
import KakaoSDKCommon
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    setUpKakaoLogin()
    FirebaseApp.configure()
    return true
  }

  private func setUpKakaoLogin() {
      guard let kakaoNativeAppKey = CofficeResources.bundle
      .object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else { return }
    KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
  }
}
