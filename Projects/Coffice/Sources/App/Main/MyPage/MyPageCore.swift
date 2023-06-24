//
//  MyPageCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct MyPage: ReducerProtocol {
  struct MenuItem: Equatable, Identifiable {
    let id = UUID()
    let menuType: MenuType

    var title: String {
      switch menuType {
      case .serviceTerms:
        return "서비스 이용 약관"
      case .privacyPolicy:
        return "개인정보 처리방침"
      case .openSources:
        return "오픈소스 라이브러리"
      case .devTest:
        return "개발자 테스트"
      }
    }
  }

  enum MenuType: CaseIterable {
    case serviceTerms
    case privacyPolicy
    case openSources
    case devTest
  }

  struct State: Equatable {
    let title = "MyPage"
    var nickName = "닉네임"
    let menuTypes: [MenuType] = MenuType.allCases
    let menuItems: [MenuItem]
    var loginType: LoginType = .anonymous

    init() {
      menuItems = menuTypes.map(MenuItem.init)
    }
  }

  enum Action: Equatable {
    case onAppear
    case menuClicked(MenuItem)
    case userInfoFetched(User)
    case pushToServiceTermsView
    case pushToPrivacyPolicy
    case pushToOpenSourcesView
    case pushToDevTestView
    case presentLoginPage
  }

  @Dependency(\.loginClient) private var loginClient

  var body: some ReducerProtocolOf<MyPage> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { send in
          do {
            let userData = try await loginClient.fetchUserData()
            await send(.userInfoFetched(userData))
          } catch {
            debugPrint(error)
          }
        }

      case .userInfoFetched(let user):
        state.loginType = user.loginType
        state.nickName = user.loginType == .anonymous ? "로그인 하러가기" : user.name
        return .none

      case .menuClicked(let menuItem):
        switch menuItem.menuType {
        case .serviceTerms:
          return EffectTask(value: .pushToServiceTermsView)
        case .privacyPolicy:
          return EffectTask(value: .pushToPrivacyPolicy)
        case .openSources:
          return EffectTask(value: .pushToOpenSourcesView)
        case .devTest:
          return EffectTask(value: .pushToDevTestView)
        }

      default:
        return .none
      }
    }
  }
}
