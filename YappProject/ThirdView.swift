//
//  ThirdView.swift
//  YappProject
//
//  Created by Min Min on 2023/05/07.
//

import ComposableArchitecture
import SwiftUI

struct ThirdView: View {
  let store: StoreOf<Third>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text(viewStore.title)
        Button {
          viewStore.send(.dismiss)
        } label: {
          Text("Dismiss The View")
        }
        Spacer()
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}
