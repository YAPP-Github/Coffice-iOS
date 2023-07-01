//
//  ToastView.swift
//  coffice
//
//  Created by 천수현 on 2023/07/01.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ToastView: View {
  private let store: StoreOf<ToastViewReducer>

  init(store: StoreOf<ToastViewReducer>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        HStack {
          viewStore.state.image.swiftUIImage
            .renderingMode(.template)
            .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
          Text(viewStore.state.title)
            .multilineTextAlignment(.center)
            .foregroundColor(viewStore.state.config.textColor)
            .applyCofficeFont(font: viewStore.state.config.font)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(viewStore.state.config.backgroundColor)
        .cornerRadius(8)
      }
      .padding(.bottom, 100)
    }
  }
}

struct ToastView_Previews: PreviewProvider {
  static var previews: some View {
    ToastView(
      store: .init(
        initialState: .mock,
        reducer: ToastViewReducer()
      )
    )
  }
}
