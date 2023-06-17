//
//  LoginView.swift
//  Cafe
//
//  Created by Min Min on 2023/05/27.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import AuthenticationServices
import ComposableArchitecture
import SwiftUI

struct LoginView: View {
  let store: StoreOf<Login>

  var body: some View {
    WithViewStore(store) { viewStore in
      mainView
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

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 10) {
        Spacer()

        Button {
          viewStore.send(.kakaoLoginButtonClicked)
        } label: {
          Text("카카오 로그인")
        }

        SignInWithAppleButton { request in
          request.requestedScopes = []
        } onCompletion: { result in
          switch result {
          case .success(let authResults):
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let token = String(data: identityToken, encoding: .utf8) else {
              return
            }
            viewStore.send(.appleLoginButtonClicked(token: token))
          case .failure(let error):
            debugPrint(error)
          }
        }
        .frame(width: 100, height: 100, alignment: .center)

        Spacer()
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
