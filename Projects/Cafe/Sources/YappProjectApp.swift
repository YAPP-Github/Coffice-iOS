//
//  YappProjectApp.swift
//  YappProject
//
//  Created by Min Min on 2023/05/06.
//

import SwiftUI

@main
struct YappProjectApp: App {
  var body: some Scene {
    WindowGroup {
      MainTabCoordinatorView(
        store: .init(
          initialState: .initialState,
          reducer: MainTabCoordinator()
        )
      )
    }
  }
}
