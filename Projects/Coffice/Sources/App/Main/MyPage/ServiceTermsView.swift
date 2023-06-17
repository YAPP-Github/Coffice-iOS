//
//  ServiceTermsView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ServiceTermsView: View {
  let store: StoreOf<ServiceTerms>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        Text("ServiceTermsView")

        Spacer()
      }
      .customNavigationBar(
        centerView: {
          Text("서비스 이용 약관")
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
  }
}

struct ServiceTermsView_Previews: PreviewProvider {
  static var previews: some View {
    ServiceTermsView(
      store: .init(
        initialState: .init(),
        reducer: ServiceTerms()
      )
    )
  }
}
