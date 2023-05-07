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
      AppView(
        store: .init(
          initialState: .init(),
          reducer: YappProject()
        )
      )
    }
  }
}
