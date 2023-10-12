//
//  AppServiceTermsView.swift
//  coffice
//
//  Created by Min Min on 2023/07/16.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct AppServiceTermsView: View {
  let store: StoreOf<AppServiceTermsReducer>

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack {
          CommonWebView(store: store.scope(
            state: \.webViewState,
            action: AppServiceTermsReducer.Action.webAction)
          )
        }
        .onAppear {
          viewStore.send(.onAppear)
        }
        .customNavigationBar(
          centerView: {
            Text(viewStore.title)
          },
          leftView: {
            Button {
              viewStore.send(.popView)
            } label: {
              Image(systemName: "chevron.left")
            }
          }
        )
      }
    )
  }
}

struct AppServiceTermsView_Previews: PreviewProvider {
  static var previews: some View {
    AppServiceTermsView(
      store: .init(
        initialState: .initialState,
        reducer: {
          AppServiceTermsReducer()
        }
      )
    )
  }
}
