//
//  CafeSearchListCell.swift
//  coffice
//
//  Created by 천수현 on 2023/07/03.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation
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
              Text(cafe.address?.address ?? "")
                .lineLimit(1)
                .clipped()
                .applyCofficeFont(font: .body2Medium)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text(cafe.isOpened ?? false ? "영업중" : "영업종료")
                .applyCofficeFont(font: .button)
                .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
              Text("월: 11:00 ~ 23:00")
                .applyCofficeFont(font: .body1Medium)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            }
          }
          Spacer()
          Button {
            // TODO: 북마크 기능 추가
          } label: {
            CofficeAsset.Asset.bookmarkLine40px.swiftUIImage
              .resizable()
              .scaledToFill()
              .frame(width: 40, height: 40)
          }
          .padding(.trailing, 20)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 0) {
            ForEach(1...10, id: \.self) { _ in
              CofficeAsset.Asset.cafeImage.swiftUIImage
                .resizable()
                .frame(width: 124, height: 112)
                .cornerRadius(4, corners: .allCorners)
                .scaledToFit()
                .padding(.trailing, 8)
            }
          }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
        HStack {
          Text("🔌 콘센트 넉넉")
            .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            .applyCofficeFont(font: .body2Medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(
              RoundedRectangle(cornerRadius: 4)
                .stroke(
                  CofficeAsset.Colors.grayScale3.swiftUIColor,
                  lineWidth: 1
                )
            )
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
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
