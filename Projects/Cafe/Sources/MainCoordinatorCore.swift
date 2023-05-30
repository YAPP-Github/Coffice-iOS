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

enum TabBarItemType: CaseIterable {
  case home
  case search
  case savedList
  case myPage

  var title: String {
    switch self {
    case .home:
      return "홈"
    case .search:
      return "검색"
    case .savedList:
      return "저장리스트"
    case .myPage:
      return "마이페이지"
    }
  }
}

struct TabBarItemViewModel: Hashable {
  let type: TabBarItemType
  let isSelected: Bool

  init(type: TabBarItemType, isSelected: Bool = false) {
    self.type = type
    self.isSelected = isSelected
  }

  var foregroundColor: Color {
    return isSelected ? .white : .gray
  }

  var backgroundColor: Color {
    return isSelected ? .black : Color(UIColor.lightGray)
  }
}

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
    var selectedTab: TabBarItemType {
      tabBarState.selectedTab
    }
  }

  enum Action: Equatable {
    case home(HomeCoordinator.Action)
    case search(SearchCoordinator.Action)
    case savedList(SavedListCoordinator.Action)
    case myPage(MyPageCoordinator.Action)
    case tabBar(TabBar.Action)
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
      case .onAppear:
        return .none

      case let .tabBar(.selectTab(itemType)):
        debugPrint("selectedTab : \(itemType)")
        return .none

      default:
        return .none
      }
    }
  }
}
