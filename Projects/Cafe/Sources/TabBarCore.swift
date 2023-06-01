//
//  TabBarCore.swift
//  Cafe
//
//  Created by Min Min on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct TabBar: ReducerProtocol {
  struct State: Equatable {
    static let initialState: State = .init()
    private let tabBarItemTypes: [TabBarItemType] = [.home, .search, .savedList, .myPage]
    private(set) var isTabBarViewPresented = true
    private(set) var tabBarItemViewModels: [TabBarItemViewModel] = [
      .init(type: .home, isSelected: true),
      .init(type: .search, isSelected: false),
      .init(type: .savedList, isSelected: false),
      .init(type: .myPage, isSelected: false)
    ]

    var selectedTab: TabBarItemType = .home {
      didSet {
        tabBarItemViewModels = tabBarItemTypes.map {
          TabBarItemViewModel(type: $0, isSelected: selectedTab == $0)
        }
      }
    }
  }

  enum Action: Equatable {
    case selectTab(TabBarItemType)
    case tabBarView(isPresented: Bool)
  }

  var body: some ReducerProtocolOf<TabBar> {
    Reduce { state, action in
      switch action {
      case .selectTab(let itemType):
        state.selectedTab = itemType
        return .none

      default:
        return .none
      }
    }
  }
}
