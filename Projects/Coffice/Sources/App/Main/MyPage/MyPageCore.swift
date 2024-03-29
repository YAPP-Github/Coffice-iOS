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

struct MyPage: Reducer {
  struct State: Equatable {
    @BindingState var contactEmailViewState: ContactEmailViewState?
    var user: User?
    var menuItems: [MenuItem] = MenuType.allCases.map(MenuItem.init)
    var versionNumber: String {
      let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
      return versionNumber ?? "1.0.0"
    }
    var bottomSheetState: BottomSheetReducer.State = .initialState
    @BindingState var shouldShowBottomSheet = false
    @BindingState var devTestViewState: DevTest.State?
    var bottomSheetType: BottomSheetType = .logout
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case bottomSheet(BottomSheetReducer.Action)
    case devTestAction(DevTest.Action)
    case fetchUserData
    case contactEmailView(isPresented: Bool)
    case onAppear
    case menuButtonTapped(MenuItem)
    case userInfoFetched(User)
    case logoutButtonTapped
    case memberLeaveButtonTapped
    case logout
    case memberLeave
    case presentDevTestView
    case loginCompletion
    case delegate(MyPageDelegate)
  }

  enum MyPageDelegate: Equatable {
    case logoutCompleted
    case memberLeaveCompleted
    case editProfileButtonTapped(nickname: String, loginType: LoginType)
  }

  @Dependency(\.accountClient) private var accountClient

  var body: some ReducerOf<MyPage> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear, .loginCompletion:
        return .send(.fetchUserData)

      case .fetchUserData:
        return .run { send in
          let userData = try await accountClient.fetchUserData()
          await send(.userInfoFetched(userData))
        } catch: { error, send in
          debugPrint(error)
        }

      case .userInfoFetched(let user):
        state.user = user
        return .none

        // MARK: MyPage Actions
      case .logout:
        return .run { send in
          _ = try await accountClient.logout()
          await send(.delegate(.logoutCompleted))
        } catch: { error, send in
          debugPrint(error)
        }

      case .memberLeave:
        return .run { send in
          _ = try await accountClient.memberLeave()
          await send(.delegate(.memberLeaveCompleted))
        } catch: { error, send in
          debugPrint(error)
        }

        // MARK: MyPageButton Tap Events
      case .menuButtonTapped(let menuItem):
        return .run { send in
          switch menuItem.menuType {
          case .logout:
            await send(.logoutButtonTapped)

          case .memberLeave:
            await send(.memberLeaveButtonTapped)

          case .contact:
            await send(.contactEmailView(isPresented: true))

          default:
            break
          }
        }

      case .logoutButtonTapped:
        state.bottomSheetType = .logout
        state.shouldShowBottomSheet = true
        return .none

      case .memberLeaveButtonTapped:
        state.bottomSheetType = .memberLeave
        state.shouldShowBottomSheet = true
        return .none

        // MARK: BottomSheetButton Tap Events
      case .bottomSheet(.confirmButtonTapped):
        state.shouldShowBottomSheet = false
        return .run { [bottomSheetType = state.bottomSheetType] send in
          switch bottomSheetType {
          case .logout:
            await send(.logout)
          case .memberLeave:
            await send(.memberLeave)
          }
        }

      case .bottomSheet(.cancelButtonTapped):
        state.shouldShowBottomSheet = false
        return .none

      case .contactEmailView(let isPresented):
        if isPresented {
          state.contactEmailViewState = .init(
            toAddress: "yapp.22nd.ios.1st@gmail.com",
            subject: "[Coffice] Feedback",
            messageHeader: """
            ✓ 이슈나 제안사항을 아래에 작성해주세요.
            도움주셔서 감사합니다. 🤗
            (Please describe your issue or feedback below.)
            """
          )
        } else {
          state.contactEmailViewState = nil
        }
        return .none

      case .presentDevTestView:
        state.devTestViewState = .initialState
        return .none

      case .devTestAction(.dismissView):
        state.devTestViewState = nil
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.devTestViewState,
      action: /MyPage.Action.devTestAction
    ) {
      DevTest()
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
          description: "정말 로그아웃 하시겠어요?",
          confirmButtonTitle: "로그아웃",
          cancelButtonTitle: "닫기"
        )
      case .memberLeave:
        return .init(
          title: "회원탈퇴",
          description: "삭제된 데이터는 복구가 불가능합니다.\n등록된 리뷰, 게시물은 탈퇴 후에도 유지되니\n삭제 후 탈퇴하시길 바랍니다.",
          confirmButtonTitle: "탈퇴하기",
          cancelButtonTitle: "닫기"
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
      case .appServiceTerms:
        return "서비스 이용약관"
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
      case .privacyPolicy, .appServiceTerms, .locationServiceTerms, .contact, .versionInformation:
        return CofficeAsset.Colors.grayScale9.swiftUIColor
      case .logout, .memberLeave:
        return CofficeAsset.Colors.grayScale6.swiftUIColor
      }
    }
  }

  enum MenuType: CaseIterable {
    case privacyPolicy
    case appServiceTerms
    case locationServiceTerms
    case contact
    case versionInformation
    case logout
    case memberLeave
  }
}
