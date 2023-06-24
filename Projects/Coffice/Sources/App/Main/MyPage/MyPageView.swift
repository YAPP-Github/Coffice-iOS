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
  private let store: StoreOf<MyPage>
  @ObservedObject private var viewStore: ViewStoreOf<MyPage>

  init(store: StoreOf<MyPage>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  var body: some View {
    mainView
      .onAppear {
        viewStore.send(.onAppear)
      }
  }

  private var mainView: some View {
    VStack(alignment: .leading, spacing: 0) {
      nickNameView
      divider
      linkedAccountTypeView
      divider
      VStack(spacing: 0) {
        ForEach(viewStore.menuItems) { menuItem in
          menuItemView(menuItem: menuItem)
        }
      }
      .padding(.vertical, 10)

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.top, 50)
  }

  private var nickNameView: some View {
    Group {
      if viewStore.state.loginType == .anonymous {
        Button {
          viewStore.send(.presentLoginPage)
        } label: {
          HStack(alignment: .center, spacing: 0) {
            Text(viewStore.state.nickName)
              .frame(maxWidth: .infinity, alignment: .leading)
              .font(.title)
            Button {
              viewStore.send(.presentLoginPage)
            } label: {
              Image(systemName: "chevron.right")
                .imageScale(.large)
            }
          }
        }
      } else {
        HStack(alignment: .center, spacing: 0) {
          Text(viewStore.state.nickName)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title)
          Button {
            viewStore.send(.presentLoginPage)
          } label: {
            Image(systemName: "chevron.right")
              .imageScale(.large)
          }
          .tint(.black)
        }
      }
    }
    .padding(.vertical, 30)
    .tint(.black)
  }

  private var linkedAccountTypeView: some View {
    HStack(alignment: .center, spacing: 0) {
      Text("연결된 계정")
        .frame(maxWidth: .infinity, alignment: .leading)
      Text(viewStore.loginType.displayName)
        .padding(.trailing, 10)
    }
    .padding(.vertical, 30)
  }

  private func menuItemView(menuItem: MyPage.MenuItem) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Button {
          viewStore.send(.menuClicked(menuItem))
        } label: {
          Text(menuItem.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50)
          Image(systemName: "chevron.right")
        }
      }
      .tint(.black)
    }
  }

  private var divider: some View {
    Divider()
      .frame(minHeight: 2)
      .overlay(Color.black)
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
