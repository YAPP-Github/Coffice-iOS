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
    WithViewStore(store, observe: { $0 }) { viewStore in
      mainView
    }
  }

  var mainView: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        VStack(alignment: .center, spacing: 0) {
          CofficeAsset.Asset.loginAppLogo.swiftUIImage
            .padding(EdgeInsets(top: 0, leading: 60, bottom: 178, trailing: 60))

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
          .padding(.bottom, 16)

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
          .padding(.bottom, 24)

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
        }
        .padding(EdgeInsets(top: 163, leading: 36, bottom: 129, trailing: 36))
      }
      .popup(
        item: viewStore.binding(
          get: \.loginServiceTermsBottomSheetState,
          send: { state in
            return .set(\.$loginServiceTermsBottomSheetState, state)
          }
        ),
        itemView: { viewState in
          LoginServiceTermsBottomSheetView(
            store: store.scope(
              state: { _ in viewState },
              action: Login.Action.loginServiceTermsBottomSheetAction
            )
          )
        },
        customize: BottomSheetContent.customize
      )
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(
      store: .init(
        initialState: .initialState,
        reducer: {
          Login()
        }
      )
    )
  }
}
