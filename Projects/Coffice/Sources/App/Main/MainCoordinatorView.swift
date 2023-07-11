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
        TabView(
          selection: viewStore.binding(\MainCoordinator.State.tabBarState.$bindableSelectedTab)
        ) {
          NavigationView {
            SearchCoordinatorView(
              store: store.scope(
                state: \.searchState,
                action: MainCoordinator.Action.search
              )
            )
          }
          .tag(TabBar.State.TabBarItemType.search)

          NavigationView {
            SavedListCoordinatorView(
              store: store.scope(
                state: \.savedListState,
                action: MainCoordinator.Action.savedList
              )
            )
          }
          .tag(TabBar.State.TabBarItemType.savedList)

          NavigationView {
            MyPageCoordinatorView(
              store: store.scope(
                state: \.myPageState,
                action: MainCoordinator.Action.myPage
              )
            )
          }
          .tag(TabBar.State.TabBarItemType.myPage)
        }
        .overlay(alignment: .bottom) {
          if viewStore.shouldShowTabBarView {
            TabBarView(
              store: store.scope(
                state: \.tabBarState,
                action: MainCoordinator.Action.tabBar
              )
            )
          } else {
            tabBarTouchBlockerView
          }

          IfLetStore(
            store.scope(
              state: \.filterSheetState,
              action: MainCoordinator.Action.filterBottomSheet
            ),
            then: CafeFilterBottomSheetView.init
          )

          IfLetStore(
            store.scope(
              state: \.commonBottomSheetState,
              action: MainCoordinator.Action.commonBottomSheet
            ),
            then: CommonBottomSheetView.init
          )

          IfLetStore(
            store.scope(
              state: \.bubbleMessageState,
              action: MainCoordinator.Action.bubbleMessage
            ),
            then: BubbleMessageView.init
          )
          .onTapGesture {
            viewStore.send(.dismissBubbleMessageView)
          }
        }
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
    }
  }
  private var tabBarTouchBlockerView: some View {
    Color.white.opacity(0.0001)
      .frame(height: 65)
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
