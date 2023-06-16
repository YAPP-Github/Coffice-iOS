//
//  MyPageView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MyPageView: View {
  let store: StoreOf<MyPage>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        VStack(spacing: 0) {
          ForEach(viewStore.menuItems) { menuItem in
            menuItemView(menuItem: menuItem)
          }
        }

        Spacer()
      }
      .customNavigationBar(centerView: {
        Text(viewStore.title)
      })
    }
  }

  func menuItemView(menuItem: MyPage.MenuItem) -> some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Button {
          viewStore.send(.menuClicked(menuItem))
        } label: {
          Text(menuItem.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50)
        }

        Divider()
          .frame(height: 1)
      }
      .padding(.horizontal, 16)
    }
  }
}

struct MyPageView_Previews: PreviewProvider {
  static var previews: some View {
    MyPageView(
      store: .init(
        initialState: .init(),
        reducer: MyPage()
      )
    )
  }
}
