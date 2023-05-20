//
//  MainCoordinatorView.swift
//  YappProject
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

/// Main Tab 화면 CoordinatorView
struct MainCoordinatorView: View {
  let store: StoreOf<MainCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) {
        CaseLet(
          state: /MainScreen.State.main,
          action: MainScreen.Action.main,
          then: AppView.init
        )
      }
    }
  }
}
