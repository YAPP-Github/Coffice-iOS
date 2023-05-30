//
//  SearchView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SearchView: View {
  let store: StoreOf<Search>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        Text("SearchView")
        Spacer()
      }
      .customNavigationBar(centerView: {
        Text(viewStore.title)
      })
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView(
      store: .init(
        initialState: .init(),
        reducer: Search()
      )
    )
  }
}
