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

struct MainTabCoordinatorView: View {
  let store: StoreOf<MainTabCoordinator>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Group {
          switch viewStore.selectedTab {
          case .home:
            HomeCoordinatorView(
              store: store.scope(
                state: \.homeState,
                action: MainTabCoordinator.Action.home
              )
            )
          case .myPage:
            MyPageCoordinatorView(
              store: store.scope(
                state: \.myPageState,
                action: MainTabCoordinator.Action.myPage
              )
            )
          }

          if viewStore.isTabBarViewPresented {
            TabBarView(store: store)
          }
        }
      }
    }
  }
}
