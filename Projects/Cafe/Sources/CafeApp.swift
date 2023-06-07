//
//  CafeApp.swift
//  Cafe
//
//  Created by Min Min on 2023/05/06.
//

import SwiftUI
import ComposableArchitecture
@main
struct CafeApp: App {
  @UIApplicationDelegateAdaptor var delegate: AppDelegate

  var body: some Scene {
    WindowGroup {
//      CafeMapView(
//        store: Store(
//          initialState: CafeMapCore.State(),
//          reducer: {
//            CafeMapCore()
//          }
//        )
//      )
      AppCoordinatorView(
        store: .init(
          initialState: .initialState,
          reducer: AppCoordinator()
        )
      )
    }
  }
}
