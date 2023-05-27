//
//  MainTabCoordinatorView.swift
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
      VStack {
        Group {
          switch viewStore.selectedTab {
          case .home:
            HomeCoordinatorView(
              store: store.scope(
                state: \.homeState,
                action: MainCoordinator.Action.home
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

          TabBarView(
            store: store.scope(
              state: \.tabBarState,
              action: MainCoordinator.Action.tabBar
            )
          )
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}
