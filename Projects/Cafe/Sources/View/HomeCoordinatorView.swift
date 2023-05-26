//
//  HomeCoordinatorView.swift
//  YappProject
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

/// Main Tab 화면 CoordinatorView
struct HomeCoordinatorView: View {
  let store: StoreOf<HomeCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) {
        CaseLet(
          state: /HomeScreen.State.main,
          action: HomeScreen.Action.main,
          then: HomeView.init
        )
      }
    }
  }
}
