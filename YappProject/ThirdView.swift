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
          debugPrint("Pop to root View")
          viewStore.send(.popToRootView)
        } label: {
          Text("😢 Pop to root View")
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
    }
  }
}
