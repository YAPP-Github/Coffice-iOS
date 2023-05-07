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
        Text(viewStore.title)
      }
      .navigationTitle(viewStore.title)
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}
