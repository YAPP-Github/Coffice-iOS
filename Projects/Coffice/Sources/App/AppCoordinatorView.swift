//
//  AppCoordinatorView.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct AppCoordinatorView: View {
  let store: StoreOf<AppCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) {
        CaseLet(
          state: /AppScreen.State.main,
          action: AppScreen.Action.main,
          then: MainCoordinatorView.init
        )

        CaseLet(
          state: /AppScreen.State.login,
          action: AppScreen.Action.login,
          then: LoginCoordinatorView.init
        )
      }
    }
    .ignoresSafeArea(.keyboard)
  }
}

struct AppCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    AppCoordinatorView(
      store: .init(
        initialState: .mock,
        reducer: AppCoordinator()
      )
    )
  }
}
