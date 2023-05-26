//
//  HomeView.swift
//  YappProject
//
//  Created by Min Min on 2023/05/06.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
  let store: StoreOf<Home>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        Text("HomeView")
        Spacer()
      }
      .customNavigationBar(centerView: {
        Text(viewStore.title)
      })
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(
      store: .init(
        initialState: .init(),
        reducer: Home()
      )
    )
  }
}
