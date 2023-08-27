//
//  MyPageScreenCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import TCACoordinators

struct MyPageScreen: Reducer {
  enum State: Equatable {
    /// 메인 페이지
    case myPage(MyPage.State)
    case privacyPolicy(PrivacyPolicy.State)
    case appServiceTerms(AppServiceTermsReducer.State)
    case locationServiceTerms(LocationServiceTerms.State)
    case editProfile(EditProfile.State)
  }

  enum Action: Equatable {
    case myPage(MyPage.Action)
    case privacyPolicy(PrivacyPolicy.Action)
    case appServiceTerms(AppServiceTermsReducer.Action)
    case locationServiceTerms(LocationServiceTerms.Action)
    case editProfile(EditProfile.Action)
  }

  var body: some ReducerOf<MyPageScreen> {
    Scope(
      state: /State.myPage,
      action: /Action.myPage
    ) {
      MyPage()
    }

    Scope(
      state: /State.privacyPolicy,
      action: /Action.privacyPolicy
    ) {
      PrivacyPolicy()
    }

    Scope(
      state: /State.appServiceTerms,
      action: /Action.appServiceTerms
    ) {
      AppServiceTermsReducer()
    }

    Scope(
      state: /State.locationServiceTerms,
      action: /Action.locationServiceTerms
    ) {
      LocationServiceTerms()
    }

    Scope(
      state: /State.editProfile,
      action: /Action.editProfile
    ) {
      EditProfile()
    }
  }
}
