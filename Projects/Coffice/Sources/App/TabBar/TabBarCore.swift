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

struct TabBar: Reducer {
  struct State: Equatable {
    static let initialState: State = .init()
    private let tabBarItemTypes: [TabBarItemType] = [.search, .savedList, .myPage]
    private(set) var isTabBarViewPresented = true
    private(set) var tabBarItemViewStates: [TabBarItemViewState] = [
      .init(type: .search, isSelected: true),
      .init(type: .savedList, isSelected: false),
      .init(type: .myPage, isSelected: false)
    ]

    @BindingState var bindableSelectedTab: TabBarItemType = .search {
      didSet {
        tabBarItemViewStates = tabBarItemTypes.map {
          TabBarItemViewState(type: $0, isSelected: bindableSelectedTab == $0)
        }
      }
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case selectTab(TabBar.State.TabBarItemType)
    case tabBarView(isPresented: Bool)
  }

  var body: some ReducerOf<TabBar> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .selectTab(let itemType):
        state.bindableSelectedTab = itemType
        return .none

      default:
        return .none
      }
    }
  }
}

extension TabBar.State {
  enum TabBarItemType: CaseIterable, Hashable {
    case search
    case savedList
    case myPage
  }

  struct TabBarItemViewState: Hashable {
    let type: TabBarItemType
    let isSelected: Bool

    init(type: TabBarItemType, isSelected: Bool = false) {
      self.type = type
      self.isSelected = isSelected
    }

    var title: String {
      switch type {
      case .search:
        return "홈"
      case .savedList:
        return "저장"
      case .myPage:
        return "MY"
      }
    }

    var image: CofficeImages {
      switch type {
      case .search:
        if isSelected {
          return CofficeAsset.Asset.homeNaviSelected44px
        } else {
          return CofficeAsset.Asset.homeNaviUnselected44px
        }

      case .savedList:
        if isSelected {
          return CofficeAsset.Asset.bookmarkNaviSelected44px
        } else {
          return CofficeAsset.Asset.bookmarkNaviUnselected44px
        }

      case .myPage:
        if isSelected {
          return CofficeAsset.Asset.mypageNaviSelected44px
        } else {
          return CofficeAsset.Asset.mypageNaviUnselected44px
        }
      }
    }
  }
}
