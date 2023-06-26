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
          Group {
            if viewStore.state.isOnboarding.isFalse {
              Button {
                viewStore.send(.dismissLoginPage)
              } label: {
                Image(systemName: "xmark")
              }
            }
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

        Button(action: {
          viewStore.send(.kakaoLoginButtonClicked)
        }, label: {
          Text("카카오 로그인")
            .tint(.black)
            .frame(maxWidth: .infinity, minHeight: 50)
            .applyCofficeFont(font: .header0)
        })
        .background(Color.yellow)
        .cornerRadius(10)

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
        .frame(height: 50)

        Button(action: {
          viewStore.send(.useAppAsNonMember)
        }, label: {
          Text("익명으로 시작하기")
            .tint(CofficeAsset.Colors.red.swiftUIColor)
            .frame(maxWidth: .infinity, minHeight: 50)
            .font(.system(size: 18, weight: .bold, design: .default))
        })
        .background(Color.pink.opacity(0.8))
        .cornerRadius(10)

        Spacer()
      }
      .padding(20)
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
