//
//  SearchCoordinatorView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct SearchCoordinatorView: View {
  let store: StoreOf<SearchCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) {
        CaseLet(
          state: /SearchScreen.State.cafeMap,
          action: SearchScreen.Action.cafeMap,
          then: CafeMapView.init
        )
      }
    }
  }
}

struct SearchCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    SearchCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: SearchCoordinator()
      )
    )
  }
}
