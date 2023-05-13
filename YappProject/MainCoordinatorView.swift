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

        CaseLet(
          state: /MainScreen.State.second,
          action: MainScreen.Action.second,
          then: SecondView.init
        )

        CaseLet(
          state: /MainScreen.State.third,
          action: MainScreen.Action.third,
          then: ThirdView.init
        )

        CaseLet(
          state: /MainScreen.State.modal,
          action: MainScreen.Action.modal,
          then: ModalView.init
        )
      }
    }
  }
}
