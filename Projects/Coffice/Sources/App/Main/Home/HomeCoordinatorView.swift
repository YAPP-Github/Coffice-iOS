//
//  HomeCoordinatorView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct HomeCoordinatorView: View {
  let store: StoreOf<HomeCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) { state in
        switch state {
        case .home:
          CaseLet(
            /HomeScreen.State.home,
            action: HomeScreen.Action.home,
            then: HomeView.init
          )
        }
      }
    }
  }
}

struct HomeCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    HomeCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: {
          HomeCoordinator()
        }
      )
    )
  }
}
