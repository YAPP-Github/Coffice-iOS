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
    WithViewStore(store, observe: { $0 }) { viewStore in
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
                LinearGradient(
                  gradient: Gradient(colors: [.black.opacity(0.06), .black.opacity(0.3)]),
                  startPoint: .top,
                  endPoint: .bottom
                )
                .background(
                  alignment: .center,
                  content: {
                    KFImage.url(URL(string: imageUrl))
                      .onFailureImage(CofficeAsset.Asset.savedListFailImagePlaceholder.image)
                      .resizable()
                      .scaledToFill()
                  }
                )
                .frame(width: viewStore.fixedImageSize, height: viewStore.fixedImageSize)
                .cornerRadius(4, corners: .allCorners)
              }
            } else {
              ForEach(1...3, id: \.self) { imageAsset in
                placeholderImage
              }
            }
          }
        }
        HStack(spacing: 11) {
          if let electricOutletLevelText = viewStore.naverMapState.selectedCafe?.electricOutletLevel.text {
            CafeTagTextView(text: electricOutletLevelText)
          }
          if let capacityLevelText = viewStore.naverMapState.selectedCafe?.capacityLevel.text {
            CafeTagTextView(text: capacityLevelText)
          }
          if let hasCommunalTableText = viewStore.naverMapState.selectedCafe?.hasCommunalTable.text {
            CafeTagTextView(text: hasCommunalTableText)
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

  var placeholderImage: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      CofficeAsset.Asset.cafePlaceholder.swiftUIImage
        .resizable()
        .frame(width: viewStore.fixedImageSize, height: viewStore.fixedImageSize)
        .scaledToFit()
        .cornerRadius(4, corners: .allCorners)
    }
  }
}

struct CafeCardView_Previews: PreviewProvider {
  static var previews: some View {
    CafeCardView(
      store: .init(
        initialState: .init(),
        reducer: {
          CafeMapCore()
        }
      )
    )
  }
}
