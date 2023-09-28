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
    WithViewStore(store, observe: { $0 }) { viewStore in
      mainView
        .overlay(
          GeometryReader { proxy in
            Color.clear.preference(key: TabBarSizePreferenceKey.self, value: proxy.size)
          }
        )
        .onPreferenceChange(TabBarSizePreferenceKey.self) { size in
          TabBarSizePreferenceKey.defaultValue = size
        }
    }
  }

  var mainView: some View {
    WithViewStore(store, observe: \.tabBarItemViewStates) { viewStore in
      VStack(spacing: 0) {
        Color(asset: CofficeAsset.Colors.grayScale3)
          .frame(height: 1)

        HStack(spacing: 0) {
          ForEach(viewStore.state, id: \.self) { viewState in
            Button {
              viewStore.send(.selectTab(viewState.type))
            } label: {
              VStack(alignment: .center, spacing: 0) {
                Image(asset: viewState.image)
                  .resizable()
                  .frame(width: 44, height: 44)

                Text(viewState.title)
                  .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale9))
                  .applyCofficeFont(font: .buttonNavi)
                  .frame(maxWidth: .infinity)
              }
            }
            .frame(height: 64)
            .background(Color(asset: CofficeAsset.Colors.grayScale1))
            .frame(maxWidth: .infinity)
          }
        }
      }
    }
  }
}

struct TabBarView_Previews: PreviewProvider {
  static var previews: some View {
    TabBarView(
      store: .init(
        initialState: .initialState,
        reducer: {
          TabBar()
        }
      )
    )
  }
}
