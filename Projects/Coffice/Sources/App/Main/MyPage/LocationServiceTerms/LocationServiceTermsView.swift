//
//  LocationServiceTermsView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct LocationServiceTermsView: View {
  let store: StoreOf<LocationServiceTerms>

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack {
          CommonWebView(store: store.scope(
            state: \.webViewState,
            action: LocationServiceTerms.Action.webAction)
          )
        }
        .customNavigationBar(
          centerView: {
            Text("위치서비스 약관")
          },
          leftView: {
            Button {
              viewStore.send(.popView)
            } label: {
              CofficeAsset.Asset.arrowLeftSLine40px.swiftUIImage
            }
          }
        )
      }
    )
  }
}

struct LocationServiceTermsView_Previews: PreviewProvider {
  static var previews: some View {
    LocationServiceTermsView(
      store: .init(
        initialState: .init(),
        reducer: {
          LocationServiceTerms()
        }
      )
    )
  }
}
