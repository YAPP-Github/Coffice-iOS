//
//  CafeMapPopupView.swift
//  coffice
//
//  Created by sehooon on 2023/07/25.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ServiceAreaPopupView: View {
  private let store: StoreOf<ServiceAreaPopup>

  init(store: StoreOf<ServiceAreaPopup>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .center, spacing: 0) {
          Text(viewStore.title)
            .applyCofficeFont(font: .header1)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .padding(.bottom, 12)
          Text(viewStore.description)
            .multilineTextAlignment(.center)
            .applyCofficeFont(font: .body1)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .padding(.bottom, 25)
          Button {
            viewStore.send(.confirmButtonTapped)
          } label: {
            Text("확인")
              .applyCofficeFont(font: .header3)
              .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
              .frame(width: 288, height: 51)
              .background(CofficeAsset.Colors.grayScale9.swiftUIColor)
              .cornerRadius(8, corners: .allCorners)
          }
          .buttonStyle(.plain)
        }
        .padding(EdgeInsets(top: 32, leading: 16, bottom: 16, trailing: 16))
        .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
        .cornerRadius(8, corners: .allCorners)
      }
    )
  }
}

struct CafeMapPopupView_Previews: PreviewProvider {
  static var previews: some View {
    ServiceAreaPopupView(store: Store.init(
      initialState: ServiceAreaPopup.State()) {
        ServiceAreaPopup()
      }
    )
  }
}
