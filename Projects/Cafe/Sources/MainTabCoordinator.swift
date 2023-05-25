//
//  MainTabCoordinator.swift
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
  case myPage

  var title: String {
    switch self {
    case .home:
      return "메인"
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

// MARK: - MainTabCoordniatorCore

struct MainTabCoordinator: ReducerProtocol {
  struct State: Equatable {
    static let initialState = MainTabCoordinator.State(
      homeState: .initialState,
      myPageState: .initialState
    )

    var homeState: HomeCoordinator.State
    var myPageState: MyPageCoordinator.State

    private let tabBarItemTypes: [TabBarItemType] = [.home, .myPage]
    private(set) var isTabBarViewPresented = true
    private(set) var tabBarItemViewModels: [TabBarItemViewModel] = [
      TabBarItemViewModel(type: .home, isSelected: true),
      TabBarItemViewModel(type: .myPage, isSelected: false)
    ]
    var selectedTab: TabBarItemType = .home {
      didSet {
        tabBarItemViewModels = tabBarItemTypes.map {
          TabBarItemViewModel(type: $0, isSelected: selectedTab == $0)
        }
      }
    }
  }

  enum Action {
    case home(HomeCoordinator.Action)
    case myPage(MyPageCoordinator.Action)
    case selectTab(TabBarItemType)
    case tabBarView(isPresented: Bool)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(state: \State.homeState, action: /Action.home) {
      HomeCoordinator()
    }

    Reduce { state, action in
      switch action {
      case .selectTab(let itemType):
        debugPrint("selectedTab : \(itemType)")
        state.selectedTab = itemType
        return .none

      default:
        return .none
      }
    }
  }
}
