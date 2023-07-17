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
    }
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        CofficeAsset.Asset.loginAppLogo.swiftUIImage
          .padding(.init(top: 163, leading: 96, bottom: 178, trailing: 96))

        Button {
          viewStore.send(.kakaoLoginButtonTapped)
        } label: {
          HStack {
            CofficeAsset.Asset.kakaoLogo18px.swiftUIImage
              .frame(width: 18, height: 18)
            Text("카카오톡으로 로그인")
              .tint(.black)
              .applyCofficeFont(font: .subtitleSemiBold)
          }
          .frame(maxWidth: .infinity)
        }
        .frame(height: 52)
        .background(CofficeAsset.Colors.kakao.swiftUIColor)
        .cornerRadius(25)

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
            viewStore.send(.appleLoginButtonTapped(token: token))
          case .failure(let error):
            debugPrint(error)
          }
        }
        .cornerRadius(25)
        .frame(height: 50)
        .padding(.top, 16)

        HStack(spacing: 4) {
          Text("회원가입 없이")
          Button {
            viewStore.send(.lookAroundButtonTapped)
          } label: {
            Text("둘러보기")
              .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
          }
        }
        .applyCofficeFont(font: .body1Medium)
        .padding(.top, 24)

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
