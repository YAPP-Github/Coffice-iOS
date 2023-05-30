//
//  MyPageCoordinatorView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct MyPageCoordinatorView: View {
  let store: StoreOf<MyPageCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) {
        CaseLet(
          state: /MyPageScreen.State.myPage,
          action: MyPageScreen.Action.myPage,
          then: MyPageView.init
        )

        CaseLet(
          state: /MyPageScreen.State.serviceTerms,
          action: MyPageScreen.Action.serviceTerms,
          then: ServiceTermsView.init
        )
      }
    }
  }
}

struct MyPageCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    MyPageCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: MyPageCoordinator()
      )
    )
  }
}
