//
//  TabBarView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct TabBarView: View {
  let store: StoreOf<TabBar>

  var body: some View {
    WithViewStore(store) { viewStore in
      if viewStore.isTabBarViewPresented {
        mainView
      } else {
        EmptyView()
      }
    }
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 0) {
        ForEach(viewStore.tabBarItemViewModels, id: \.self) { viewModel in
          Button {
            viewStore.send(.selectTab(viewModel.type))
          } label: {
            Text(viewModel.type.title)
              .foregroundColor(viewModel.foregroundColor)
              .frame(maxWidth: .infinity)
          }
          .frame(height: 40)
          .background(viewModel.backgroundColor)
          .frame(maxWidth: .infinity)
        }
      }
    }
  }
}
