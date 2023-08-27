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
      SwitchStore(screen) { state in
        switch state {
        case .myPage:
          CaseLet(
            /MyPageScreen.State.myPage,
            action: MyPageScreen.Action.myPage,
            then: MyPageView.init
          )
        case .locationServiceTerms:
          CaseLet(
            /MyPageScreen.State.locationServiceTerms,
            action: MyPageScreen.Action.locationServiceTerms,
            then: LocationServiceTermsView.init
          )
        case .appServiceTerms:
          CaseLet(
            /MyPageScreen.State.appServiceTerms,
            action: MyPageScreen.Action.appServiceTerms,
            then: AppServiceTermsView.init
          )
        case .privacyPolicy:
          CaseLet(
            /MyPageScreen.State.privacyPolicy,
            action: MyPageScreen.Action.privacyPolicy,
            then: PrivacyPolicyView.init
          )
        case .editProfile:
          CaseLet(
            /MyPageScreen.State.editProfile,
            action: MyPageScreen.Action.editProfile,
            then: EditProfileView.init
          )
        }
      }
    }
  }
}

struct MyPageCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    MyPageCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: {
          MyPageCoordinator()
        }
      )
    )
  }
}
