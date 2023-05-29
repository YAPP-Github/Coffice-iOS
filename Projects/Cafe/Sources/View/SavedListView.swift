//
//  SavedListView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SavedListView: View {
  let store: StoreOf<SavedList>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        Text("SavedListView")
        Spacer()
      }
      .customNavigationBar(centerView: {
        Text(viewStore.title)
      })
    }
  }
}

struct SavedListView_Previews: PreviewProvider {
  static var previews: some View {
    SavedListView(
      store: .init(
        initialState: .init(),
        reducer: SavedList()
      )
    )
  }
}
