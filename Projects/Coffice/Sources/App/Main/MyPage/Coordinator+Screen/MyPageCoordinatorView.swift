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
          state: /MyPageScreen.State.locationServiceTerms,
          action: MyPageScreen.Action.locationServiceTerms,
          then: LocationServiceTermsView.init
        )

        CaseLet(
          state: /MyPageScreen.State.privacyPolicy,
          action: MyPageScreen.Action.privacyPolicy,
          then: PrivacyPolicyView.init
        )

        CaseLet(
          state: /MyPageScreen.State.editProfile,
          action: MyPageScreen.Action.editProfile,
          then: EditProfileView.init
        )

        CaseLet(
          state: /MyPageScreen.State.commonBottomSheet,
          action: MyPageScreen.Action.commonBottomSheet,
          then: CommonBottomSheetView.init
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
