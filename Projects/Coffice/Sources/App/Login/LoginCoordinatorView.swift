//
//  LoginCoordinatorView.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct LoginCoordinatorView: View {
  let store: StoreOf<LoginCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) { _ in
        CaseLet(
          /LoginScreen.State.main,
          action: LoginScreen.Action.main,
          then: LoginView.init
        )
      }
    }
  }
}

struct LoginCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    LoginCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: {
          LoginCoordinator()
        }
      )
    )
  }
}
