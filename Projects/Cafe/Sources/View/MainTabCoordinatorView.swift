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
          case .main:
            HomeCoordinatorView(
              store: store.scope(
                state: \.homeState,
                action: MainTabCoordinator.Action.main
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
