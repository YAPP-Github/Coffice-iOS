//
//  CafeSearchListCell.swift
//  coffice
//
//  Created by 천수현 on 2023/07/03.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Kingfisher
import SwiftUI

struct CafeSearchListCell: View {
  let store: StoreOf<CafeSearchListCore>
  let cafe: Cafe

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .top, spacing: 0) {
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text(cafe.name)
                .fixedSize(horizontal: true, vertical: true)
                .clipped()
                .applyCofficeFont(font: CofficeFont.header2)
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
              Text(cafe.address?.simpleAddress ?? "")
                .lineLimit(1)
                .clipped()
                .applyCofficeFont(font: .body2Medium)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text(cafe.openingStateDescription)
                .applyCofficeFont(font: .button)
                .foregroundColor(cafe.openingStateTextColor)
              Text(cafe.todayRunningTimeDescription)
                .applyCofficeFont(font: .body1Medium)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            }
          }
          Spacer()
          Button {
            viewStore.send(.bookmarkButtonTapped(cafe: cafe))
          } label: {
            cafe.bookmarkImage
              .resizable()
              .frame(width: 40, height: 40)
              .scaledToFill()
          }
          .padding(.trailing, 20)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            if let imageUrls = cafe.imageUrls, imageUrls.isNotEmpty {
              ForEach(imageUrls, id: \.self) { imageUrl in
                KFImage.url(URL(string: imageUrl))
                  .resizable()
                  .frame(width: 124, height: 112)
                  .scaledToFit()
                  .cornerRadius(4, corners: .allCorners)
              }
            } else {
              ForEach(1...3, id: \.self) { imageAsset in
                CofficeAsset.Asset.cafeImage.swiftUIImage
                  .resizable()
                  .frame(width: 124, height: 112)
                  .scaledToFit()
                  .cornerRadius(4, corners: .allCorners)
              }
            }
          }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
        HStack(spacing: 11) {
          if let electricOutletLevelText = cafe.electricOutletLevelToText {
            Text(electricOutletLevelText)
              .cafeTagTextModifier()
          }
          if let capacityLevelText = cafe.capacityLevelToText {
            Text(capacityLevelText)
              .cafeTagTextModifier()
          }
          if let hasCommunalTableText = cafe.hasCommunalTableToText {
            Text(hasCommunalTableText)
              .cafeTagTextModifier()
          }
        }
      }
    }
  }
}

struct CafeSearchListCell_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchListCell(
      store: .init(
        initialState: .init(filterMenusState: .mock),
        reducer: CafeSearchListCore()
      ),
      cafe: Cafe.dummy
    )
  }
}
