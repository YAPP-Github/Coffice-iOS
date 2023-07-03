//
//  MainCoordinatorCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

// MARK: - MainCoordniatorCore

struct MainCoordinator: ReducerProtocol {
  struct State: Equatable {
    static let initialState = MainCoordinator.State(
      homeState: .initialState,
      searchState: .initialState,
      savedListState: .initialState,
      myPageState: .initialState,
      tabBarState: .init()
    )

    var homeState: HomeCoordinator.State
    var searchState: SearchCoordinator.State
    var savedListState: SavedListCoordinator.State
    var myPageState: MyPageCoordinator.State
    var tabBarState: TabBar.State
    var selectedTab: TabBar.State.TabBarItemType {
      tabBarState.selectedTab
    }

    var filterSheetState: FilterSheetCore.State?
    var bubbleMessageState: BubbleMessage.State?
    var toastMessageState: Toast.State?
  }

  enum Action: Equatable {
    case home(HomeCoordinator.Action)
    case search(SearchCoordinator.Action)
    case savedList(SavedListCoordinator.Action)
    case myPage(MyPageCoordinator.Action)
    case tabBar(TabBar.Action)
    case filterSheetAction(FilterSheetCore.Action)
    case bubbleMessage(BubbleMessage.Action)
    case toastMessage(Toast.Action)
    case dismissToastMessageView
    case dismissBubbleMessageView
    case onAppear
  }

  var body: some ReducerProtocolOf<MainCoordinator> {
    Scope(state: \State.homeState, action: /Action.home) {
      HomeCoordinator()
    }

    Scope(state: \State.searchState, action: /Action.search) {
      SearchCoordinator()
    }

    Scope(state: \State.savedListState, action: /Action.savedList) {
      SavedListCoordinator()
    }

    Scope(state: \State.myPageState, action: /Action.myPage) {
      MyPageCoordinator()
    }

    Scope(state: \State.tabBarState, action: /Action.tabBar) {
      TabBar()
    }

    Reduce { state, action in
      switch action {
      case .filterSheetAction(.buttonTapped(let index, let optionType)):
        switch optionType {
        case .outlet:
          state.filterSheetState?.outletButtonViewState[index].currentTappedState.toggle()
          return .none

        case .spaceSize:
          state.filterSheetState?.spaceSizeButtonViewState[index].currentTappedState.toggle()
          return .none

        case .drink:
          return .none

        default:
          return .none
        }

      case .filterSheetAction(.dismiss):
        state.filterSheetState = nil
        return .none

      case .onAppear:
        return .none

      case let .tabBar(.selectTab(itemType)):
        debugPrint("selectedTab : \(itemType)")
        return .none

      case .search(
        .routeAction(_, .cafeSearchList(.presentFilterSheetView(let filterSheetState)))
      ):
        state.filterSheetState = filterSheetState
        return .none

      case .search(
        .routeAction(_, .cafeSearchDetail(.presentBubbleMessageView(let bubbleMessageState)))
      ):
        state.bubbleMessageState = bubbleMessageState
        return .none

      case .search(
        .routeAction(_, .cafeMap(.showToast(let toastMessageState)))
      ):
        state.toastMessageState = toastMessageState
        return .run { send in
          try await Task.sleep(nanoseconds: 2_000_000_000) // 2초
          await send(.dismissToastMessageView)
        }

      case .dismissBubbleMessageView:
        state.bubbleMessageState = nil
        return .none

      case .dismissToastMessageView:
        state.toastMessageState = nil
        return .none

      default:
        return .none
      }
    }
  }
}
