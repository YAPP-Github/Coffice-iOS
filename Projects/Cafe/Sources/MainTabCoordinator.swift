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
  case main

  var title: String {
    switch self {
    case .main:
      return "메인"
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
      homeState: .initialState
    )

    var homeState: HomeCoordinator.State

    private let tabBarItemTypes: [TabBarItemType] = [.main]
    private(set) var tabBarItemViewModels: [TabBarItemViewModel] = [
      TabBarItemViewModel(type: .main, isSelected: true)
    ]

    private(set) var isTabBarViewPresented = true
    var selectedTab: TabBarItemType = .main {
      didSet {
        tabBarItemViewModels = tabBarItemTypes.map {
          TabBarItemViewModel(type: $0, isSelected: selectedTab == $0)
        }
      }
    }
  }

  enum Action {
    case main(HomeCoordinator.Action)
    case selectTab(TabBarItemType)
    case tabBarView(isPresented: Bool)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(state: \State.homeState, action: /Action.main) {
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
