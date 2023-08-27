//
//  BubbleMessageView.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/06/27.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct BubbleMessageView: View {
  private let store: StoreOf<BubbleMessage>

  init(store: StoreOf<BubbleMessage>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 0) {
          Text(viewStore.title)
            .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale8))
            .applyCofficeFont(font: .button)
            .frame(height: 20, alignment: .leading)
          Text(viewStore.subTitle)
            .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale6))
            .applyCofficeFont(font: .body2)
            .frame(height: 20, alignment: .leading)

          VStack(spacing: 10) {
            ForEach(viewStore.subInfoViewStates) { subInfoViewState in
              HStack(spacing: 0) {
                Image(subInfoViewState.iconImageName)
                  .resizable()
                  .frame(width: 20, height: 20)
                Text(subInfoViewState.title)
                  .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale8))
                  .applyCofficeFont(font: .body2Medium)
                  .padding(.leading, 8)
                Text(subInfoViewState.description)
                  .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
                  .applyCofficeFont(font: .body2Medium)
                  .padding(.leading, 4)

                Spacer()
              }
              .frame(height: 20)
            }
          }
          .padding(.top, 24)
        }
        .padding(20)
        .frame(width: 210, alignment: .center)
        .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
        .cornerRadius(8)
      }
    }
  }
}

struct BubbleMessageView_Previews: PreviewProvider {
  static var previews: some View {
    BubbleMessageView(
      store: .init(
        initialState: .mock,
        reducer: {
          BubbleMessage()
        }
      )
    )
  }
}
