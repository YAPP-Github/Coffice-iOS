//
//  MainCoordinatorView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct MainCoordinatorView: View {
  let store: StoreOf<MainCoordinator>

  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        NavigationView {
          mainView
        }
        tabBarView
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      Group {
        switch viewStore.selectedTab {
        case .home:
          HomeCoordinatorView(
            store: store.scope(
              state: \.homeState,
              action: MainCoordinator.Action.home
            )
          )
        case .search:
          SearchCoordinatorView(
            store: store.scope(
              state: \.searchState,
              action: MainCoordinator.Action.search
            )
          )
        case .savedList:
          SavedListCoordinatorView(
            store: store.scope(
              state: \.savedListState,
              action: MainCoordinator.Action.savedList
            )
          )
        case .myPage:
          MyPageCoordinatorView(
            store: store.scope(
              state: \.myPageState,
              action: MainCoordinator.Action.myPage
            )
          )
        }
      }
    }
  }

  var tabBarView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        TabBarView(
          store: store.scope(
            state: \.tabBarState,
            action: MainCoordinator.Action.tabBar
          )
        )
      }
    }
  }
}

struct MainCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    MainCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: MainCoordinator()
      )
    )
  }
}
