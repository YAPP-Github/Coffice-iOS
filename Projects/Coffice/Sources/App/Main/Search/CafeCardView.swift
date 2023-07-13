//
//  CafeCardView.swift
//  coffice
//
//  Created by sehooon on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeCardView: View {
  let store: StoreOf<CafeMapCore>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: .top, spacing: 0) {
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text(viewStore.selectedCafe?.name ?? "")
                .lineLimit(1)
                .applyCofficeFont(font: .header2)
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
              Text(viewStore.selectedCafe?.address?.simpleAddress ?? "")
                .lineLimit(1)
                .applyCofficeFont(font: .body2Medium)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text("영업중")
                .applyCofficeFont(font: .button)
                .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
              Text("월: 11:00 ~ 21:30")
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
            viewStore.send(.cardViewBookmarkButtonTapped(cafe: viewStore.selectedCafe ?? .dummy))
          } label: {
            Group {
              if viewStore.selectedCafe?.isBookmarked == true {
                CofficeAsset.Asset.bookmarkFill40px.swiftUIImage
              } else {
                CofficeAsset.Asset.bookmarkLine40px.swiftUIImage
              }
            }
            .frame(width: 40, height: 40)
            .scaledToFill()
          }
        }
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(1...10, id: \.self) { _ in
              Image(uiImage: CofficeAsset.Asset.cafeImage.image)
                .resizable()
                .frame(
                  width: viewStore.fixedImageSize,
                  height: viewStore.fixedImageSize
                )
                .scaledToFit()
                .cornerRadius(4, corners: .allCorners)
            }
          }
        }
        HStack(spacing: 0) {
          Text("🔌 콘센트 넉넉")
            .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            .applyCofficeFont(font: .body2Medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
              RoundedRectangle(cornerRadius: 4)
                .stroke(
                  CofficeAsset.Colors.grayScale3.swiftUIColor,
                  lineWidth: 1
                )
            )
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
