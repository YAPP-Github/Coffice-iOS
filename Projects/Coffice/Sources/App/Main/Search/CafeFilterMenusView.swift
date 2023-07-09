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
            ForEach(viewStore.buttonViewStates) { viewState in
              Button {
                viewStore.send(.filterButtonTapped(viewState.menuType))
              } label: {
                switch viewState.menuType {
                case .detail:
                  CofficeAsset.Asset.filterLine24px.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .scaledToFit()
                    .foregroundColor(viewState.foregroundColorAsset.swiftUIColor)
                    .frame(width: viewState.menuType.size.width, height: viewState.menuType.size.height)
                    .cornerRadius(16)
                    .background(viewState.backgroundColorAsset.swiftUIColor.clipShape(Capsule()))
                    .overlay(
                      RoundedRectangle(cornerRadius: 18)
                        .stroke(viewState.borderColorAsset.swiftUIColor, lineWidth: 1)
                    )
                default:
                  HStack(spacing: 0) {
                    Text(viewState.menuType.title)
                      .foregroundColor(viewState.foregroundColorAsset.swiftUIColor)
                      .applyCofficeFont(font: .body1Medium)
                    CofficeAsset.Asset.arrowDropDownLine18px.swiftUIImage
                      .resizable()
                      .renderingMode(.template)
                      .frame(width: 18, height: 18)
                      .foregroundColor(viewState.foregroundColorAsset.swiftUIColor)
                  }
                  .frame(height: viewState.menuType.size.height)
                  .padding(.leading, 16)
                  .padding(.trailing, 8)
                  .cornerRadius(18)
                  .background(viewState.backgroundColorAsset.swiftUIColor.clipShape(Capsule()))
                  .overlay(
                    RoundedRectangle(cornerRadius: 18)
                      .stroke(viewState.borderColorAsset.swiftUIColor, lineWidth: 1)
                  )
                }
              }
              .cornerRadius(18)
            }
          }
          .padding(.horizontal, 20)
        }
        .frame(width: 355, height: 36)
        .padding(.bottom, 16)
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
