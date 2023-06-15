//
//  PrivacyPolicyView.swift
//  Cafe
//
//  Created by Min Min on 2023/06/15.
//  Copyright (c) 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct PrivacyPolicyView: View {
  let store: StoreOf<PrivacyPolicy>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 10) {

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
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
  static var previews: some View {
    PrivacyPolicyView(
      store: .init(
        initialState: .initialState,
        reducer: PrivacyPolicy()
      )
    )
  }
}
