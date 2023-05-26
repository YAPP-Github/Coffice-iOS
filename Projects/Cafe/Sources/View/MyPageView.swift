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
  let store: StoreOf<MyPage>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        Text("MyPageView")
        Spacer()
      }
      .customNavigationBar(centerView: {
        Text(viewStore.title)
      })
    }
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
