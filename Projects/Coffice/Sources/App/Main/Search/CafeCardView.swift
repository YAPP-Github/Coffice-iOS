//
//  CafeCardView.swift
//  coffice
//
//  Created by sehooon on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct CafeCardView: View {
  let store: StoreOf<CafeMapCore>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: .top, spacing: 0) {
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text(viewStore.naverMapState.selectedCafe?.name ?? "")
                .lineLimit(1)
                .applyCofficeFont(font: .header2)
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
              Text(viewStore.naverMapState.selectedCafe?.address?.simpleAddress ?? "")
                .lineLimit(1)
                .applyCofficeFont(font: .body2Medium)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text(viewStore.naverMapState.selectedCafe?.openingStateDescription ?? "")
                .applyCofficeFont(font: .button)
                .foregroundColor(viewStore.naverMapState.selectedCafe?.openingStateTextColor)
              Text(viewStore.naverMapState.selectedCafe?.todayRunningTimeDescription ?? "")
                .applyCofficeFont(font: .body1Medium)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            }
          }
          .frame(
            maxWidth: viewStore.fixedCardTitleSize,
            alignment: .leading
          )
          Spacer()
          Button {
            viewStore.send(
              .naverMapAction(
                .cardViewBookmarkButtonTapped(
                  cafe: viewStore.naverMapState.selectedCafe ?? .dummy
                )
              )
            )
          } label: {
            viewStore.naverMapState.selectedCafe?.bookmarkImage
              .frame(width: 40, height: 40)
              .scaledToFill()
          }
        }
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            if let imageUrls = viewStore.naverMapState.selectedCafe?.imageUrls, imageUrls.isNotEmpty {
              ForEach(imageUrls, id: \.self) { imageUrl in
                KFImage.url(URL(string: imageUrl))
                  .resizable()
                  .frame(width: viewStore.fixedImageSize, height: viewStore.fixedImageSize)
                  .scaledToFit()
                  .cornerRadius(4, corners: .allCorners)
              }
            } else {
              ForEach(1...3, id: \.self) { imageAsset in
                CofficeAsset.Asset.cafeImage.swiftUIImage
                  .resizable()
                  .frame(width: viewStore.fixedImageSize, height: viewStore.fixedImageSize)
                  .scaledToFit()
                  .cornerRadius(4, corners: .allCorners)
              }
            }
          }
        }
        HStack(spacing: 11) {
          if let electricOutletLevelText = viewStore.naverMapState.selectedCafe?.electricOutletLevelToText {
            Text(electricOutletLevelText)
              .cafeTagTextModifier()
          }
          if let capacityLevelText = viewStore.naverMapState.selectedCafe?.capacityLevelToText {
            Text(capacityLevelText)
              .cafeTagTextModifier()
          }
          if let hasCommunalTableText = viewStore.naverMapState.selectedCafe?.hasCommunalTableToText {
            Text(hasCommunalTableText)
              .cafeTagTextModifier()
          }
        }
      }
      .padding(EdgeInsets(top: 24, leading: 20, bottom: 20, trailing: 20))
      .background {
        Rectangle()
          .foregroundColor(.white)
          .cornerRadius(12, corners: [.topLeft, .topRight])
          .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 0)
      }
    }
  }
}

struct CafeCardView_Previews: PreviewProvider {
  static var previews: some View {
    CafeCardView(
      store: .init(
        initialState: .init(),
        reducer: CafeMapCore()
      )
    )
  }
}
