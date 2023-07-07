//
//  MyPageCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct MyPage: ReducerProtocol {
  struct MenuItem: Equatable, Identifiable {
    let id = UUID()
    let menuType: MenuType

    var title: String {
      switch menuType {
      case .privacyPolicy:
        return "개인정보 처리방침"
      case .locationServiceTerms:
        return "위치서비스 약관"
      case .contact:
        return "문의하기"
      case .versionInformation:
        return "버전 정보"
      case .logout:
        return "로그아웃"
      case .memberLeave:
        return "회원탈퇴"
      }
    }

    var textColor: Color {
      switch menuType {
      case .privacyPolicy, .locationServiceTerms, .contact, .versionInformation:
        return CofficeAsset.Colors.grayScale9.swiftUIColor
      case .logout, .memberLeave:
        return CofficeAsset.Colors.grayScale6.swiftUIColor
      }
    }
  }

  enum MenuType: CaseIterable {
    case privacyPolicy
    case locationServiceTerms
    case contact
    case versionInformation
    case logout
    case memberLeave
  }

  struct State: Equatable {
    let title = "MyPage"
    var nickName = "닉네임"
    var menuItems: [MenuItem] = MenuType.allCases.map(MenuItem.init)
    var loginType: LoginType = .anonymous
    var shouldShowDevTestMenu = false
    var versionNumber: String {
      let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
      return versionNumber ?? "1.0.0"
    }

    init() {
      menuItems = MenuType.allCases.map(MenuItem.init)
    }
  }

  enum Action: Equatable {
    case onAppear
    case menuButtonTapped(MenuItem)
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
          let userData = try await loginClient.fetchUserData()
          await send(.userInfoFetched(userData))
        } catch: { error, send in
          debugPrint(error)
        }

      case .userInfoFetched(let user):
        state.loginType = user.loginTypes.first!
        state.nickName = user.loginTypes.first == .anonymous ? "로그인 하러가기" : user.name
        return .none

      case .menuButtonTapped(let menuItem):
        switch menuItem.menuType {
        case .privacyPolicy:
          return EffectTask(value: .pushToPrivacyPolicy)
        case .locationServiceTerms:
          return EffectTask(value: .pushToServiceTermsView)
        case .contact:
          return .none // TODO: 메뉴 탭시 동작 채우기
        case .versionInformation:
          return .none
        case .logout:
          return .none
        case .memberLeave:
          return .none
        }

      default:
        return .none
      }
    }
  }
}
