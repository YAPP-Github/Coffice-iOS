//
//  HomeView.swift
//  Cafe
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
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack {
          Spacer()
          Text("HomeView")
            .padding(.bottom, 10)
          Button {
            viewStore.send(.pushLoginView)
          } label: {
            Text("로그인")
          }
          Spacer()
        }
        .customNavigationBar(centerView: {
          Text(viewStore.title)
        })
      }
    )
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(
      store: .init(
        initialState: .init(),
        reducer: {
          Home()
        }
      )
    )
  }
}
