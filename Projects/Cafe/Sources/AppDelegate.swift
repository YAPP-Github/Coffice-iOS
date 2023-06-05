//
//  AppDelegate.swift
//  Cafe
//
//  Created by Min Min on 2023/06/03.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Firebase
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
