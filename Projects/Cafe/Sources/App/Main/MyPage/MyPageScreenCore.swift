//
//  MyPageScreenCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/09.
//

import ComposableArchitecture
import TCACoordinators

struct MyPageScreen: ReducerProtocol {
  enum State: Equatable {
    /// 메인 페이지
    case myPage(MyPage.State)
    case serviceTerms(ServiceTerms.State)
    case privacyPolicy(PrivacyPolicy.State)
    case openSources(OpenSources.State)
    case devTest(DevTest.State)
  }

  enum Action: Equatable {
    case myPage(MyPage.Action)
    case serviceTerms(ServiceTerms.Action)
    case privacyPolicy(PrivacyPolicy.Action)
    case openSources(OpenSources.Action)
    case devTest(DevTest.Action)
  }

  var body: some ReducerProtocolOf<MyPageScreen> {
    Scope(
      state: /State.myPage,
      action: /Action.myPage
    ) {
      MyPage()
    }

    Scope(
      state: /State.serviceTerms,
      action: /Action.serviceTerms
    ) {
      ServiceTerms()
    }

    Scope(
      state: /State.privacyPolicy,
      action: /Action.privacyPolicy
    ) {
      PrivacyPolicy()
    }

    Scope(
      state: /State.openSources,
      action: /Action.openSources
    ) {
      OpenSources()
    }

    Scope(
      state: /State.devTest,
      action: /Action.devTest
    ) {
      DevTest()
    }
  }
}
