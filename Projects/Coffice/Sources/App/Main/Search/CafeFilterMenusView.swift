//
//  CafeFilterMenusView.swift
//  coffice
//
//  Created by Min Min on 2023/07/08.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeFilterMenusView: View {
  private let store: StoreOf<CafeFilterMenus>

  init(store: StoreOf<CafeFilterMenus>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(viewStore.filterOrders, id: \.self) { filter in
              Button {
                viewStore.send(.filterButtonTapped(filter))
              } label: {
                if filter == .detail {
                  Image(asset: CofficeAsset.Asset.filterLine24px)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .scaledToFit()
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                    .frame(width: filter.size.width, height: filter.size.height)
                    .overlay(
                      RoundedRectangle(cornerRadius: 18)
                        .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
                    )
                } else {
                  HStack(alignment: .center, spacing: 0) {
                    Text(filter.title)
                      .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                      .applyCofficeFont(font: .body1Medium)
                    Image(asset: CofficeAsset.Asset.arrowDropDownLine18px)
                      .resizable()
                      .renderingMode(.template)
                      .frame(width: 18, height: 18)
                      .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                  }
                  .frame(width: filter.size.width, height: filter.size.height)
                  .overlay(
                    RoundedRectangle(cornerRadius: 18)
                      .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
                  )
                }
              }
              .cornerRadius(18)
            }
          }
        }
        .frame(width: 355, height: 36)
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

struct CafeFilterMenusView_Previews: PreviewProvider {
  static var previews: some View {
    CafeFilterMenusView(
      store: .init(
        initialState: .mock,
        reducer: CafeFilterMenus()
      )
    )
  }
}
