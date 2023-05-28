//
//  CafeApp.swift
//  Cafe
//
//  Created by Min Min on 2023/05/06.
//

import SwiftUI

@main
struct CafeApp: App {
  var body: some Scene {
    WindowGroup {
      AppCoordinatorView(
        store: .init(
          initialState: .initialState,
          reducer: AppCoordinator()
        )
      )
    }
  }
}
