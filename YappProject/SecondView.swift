//
//  SecondView.swift
//  YappProject
//
//  Created by Min Min on 2023/05/07.
//

import ComposableArchitecture
import SwiftUI

struct SecondView: View {
  let store: StoreOf<Second>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Button {
          viewStore.send(.thirdActive(true))
        } label: {
          Text("😀 Push Navigation View")
            .foregroundColor(.blue)
            .frame(height: 50.0)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16.0)
        }
      }
      .navigationTitle(viewStore.title)
      .onAppear {
        viewStore.send(.onAppear)
      }
      .background(emptyNavigationLink)
    }
  }

  var emptyNavigationLink: some View {
    WithViewStore(store) { viewStore in
      NavigationLink(
        destination: IfLetStore(
          store.scope(
            state: \.thirdState,
            action: Second.Action.third
          ),
          then: ThirdView.init
        ),
        isActive: viewStore.binding(
          get: \.isThirdActive,
          send: Second.Action.thirdActive
        ),
        label: {
          EmptyView()
        }
      )
    }
  }
}
