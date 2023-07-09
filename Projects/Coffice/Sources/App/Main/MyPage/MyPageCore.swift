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
    var user: User?
    var menuItems: [MenuItem] = MenuType.allCases.map(MenuItem.init)
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
    case editProfileButtonTapped
    case userInfoFetched(User)
    case pushToLocationServiceTermsView
    case pushToPrivacyPolicy
    case pushToContactView
    case pushToEditProfile
    case presentLoginPage
    case showCommonBottomSheet(
      title: String,
      description: String,
      cancelButtonTitle: String,
      confirmButtonTitle: String
    )
    case presentCommonBottomSheet(CommonBottomSheet.State)
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
        state.user = user
        return .none

      case .editProfileButtonTapped:
        return EffectTask(value: .pushToEditProfile)

      case .menuButtonTapped(let menuItem):
        switch menuItem.menuType {
        case .privacyPolicy:
          return EffectTask(value: .pushToPrivacyPolicy)

        case .locationServiceTerms:
          return EffectTask(value: .pushToLocationServiceTermsView)

        case .contact:
          return EffectTask(value: .pushToContactView)

        case .versionInformation:
          return .none

        case .logout:
          return EffectTask(
            value: .presentCommonBottomSheet(
              .init(
                title: "로그아웃",
                description: "정말 로그아웃 하시겠어요?",
                cancelButtonTitle: "나가기",
                confirmButtonTitle: "로그아웃"
              )
            )
          )

        case .memberLeave:
          return EffectTask(
            value: .presentCommonBottomSheet(
              .init(
                title: "회원탈퇴",
                description: "삭제된 데이터는 복구가 불가능합니다.\n등록된 리뷰, 게시물은 탈퇴 후에도 유지되니\n삭제 후 탈퇴하시길 바랍니다. ",
                cancelButtonTitle: "닫기",
                confirmButtonTitle: "탈퇴하기"
              )
            )
          )
        }

      default:
        return .none
      }
    }
  }
}
