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
  struct State: Equatable {
    var user: User?
    var menuItems: [MenuItem] = MenuType.allCases.map(MenuItem.init)
    var versionNumber: String {
      let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
      return versionNumber ?? "1.0.0"
    }
    var bottomSheetState: BottomSheetReducer.State = .initialState
    @BindingState var shouldShowBottomSheet = false
    var bottomSheetType: BottomSheetType = .logout
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case bottomSheet(BottomSheetReducer.Action)
    case onAppear
    case menuButtonTapped(MenuItem)
    case editProfileButtonTapped(nickname: String)
    case userInfoFetched(User)
    case logoutButtonTapped
    case memberLeaveButtonTapped
    case logout
    case memberLeave
  }

  @Dependency(\.loginClient) private var loginClient

  var body: some ReducerProtocolOf<MyPage> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

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

      case .bottomSheet(.confirmButtonTapped):
        return .run { [bottomSheetType = state.bottomSheetType] send in
          switch bottomSheetType {
          case .logout:
            await send(.logout)
          case .memberLeave:
            await send(.memberLeave)
          }
        }

      case .menuButtonTapped(let menuItem):
        return .run { send in
          switch menuItem.menuType {
          case .logout:
            await send(.logoutButtonTapped)

          case .memberLeave:
            await send(.memberLeaveButtonTapped)

          default:
            break
          }
        }

      case .logout:
        return .none

      case .memberLeave:
        return .none

      case .bottomSheet(.cancelButtonTapped):
        state.shouldShowBottomSheet = false
        return .none

      case .logoutButtonTapped:
        state.bottomSheetType = .logout
        state.shouldShowBottomSheet = true
        return .none

      case .memberLeaveButtonTapped:
        state.bottomSheetType = .memberLeave
        state.shouldShowBottomSheet = true
        return .none

      default:
        return .none
      }
    }
  }
}

extension MyPage {
  enum BottomSheetType {
    case logout
    case memberLeave

    var content: BottomSheetContent {
      switch self {
      case .logout:
        return .init(
          title: "로그아웃",
          description: "내용",
          confirmButtonTitle: "확인",
          cancelButtonTitle: "취소"
        )
      case .memberLeave:
        return .init(
          title: "회원탈퇴",
          description: "내용",
          confirmButtonTitle: "확인",
          cancelButtonTitle: "취소"
        )
      }
    }
  }
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
}
