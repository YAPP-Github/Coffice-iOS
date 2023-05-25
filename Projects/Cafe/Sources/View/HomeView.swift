//
//  AppView.swift
//  YappProject
//
//  Created by Min Min on 2023/05/06.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
  let store: StoreOf<YappProject>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
      }
      .navigationTitle(viewStore.title)
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(
      store: .init(
        initialState: .init(),
        reducer: YappProject()
      )
    )
  }
}
