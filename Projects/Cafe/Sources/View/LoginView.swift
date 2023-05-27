//
//  LoginView.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct LoginView: View {
  let store: StoreOf<Login>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 10) {
        Spacer()

        Button {
          viewStore.send(.kakaoLoginButtonClicked)
        } label: {
          Text("카카오 로그인")
        }
        
        Button {
          viewStore.send(.appleLoginButtonClicked)
        } label: {
          Text("애플 로그인")
        }

        Spacer()
      }
      .customNavigationBar {
        Text(viewStore.title)
      } leftView: {
        Button {
          viewStore.send(.useAppAsNonMember)
        } label: {
          Text("둘러보기")
        }
      } rightView: {
        EmptyView()
      }
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(
      store: .init(
        initialState: .initialState,
        reducer: Login()
      )
    )
  }
}
