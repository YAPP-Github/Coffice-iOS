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
  let cafe: Cafe

  var body: some View {
    WithViewStore(store) { viewStore in
      Rectangle()
        .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale1))
        .cornerRadius(12, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 0)
        .overlay {
          VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
              VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                  Text(cafe.name)
                    .lineLimit(1)
                    .applyCofficeFont(font: CofficeFont.header2)
                    .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale9))
                  Text(cafe.address?.address ?? "")
                    .lineLimit(1)
                    .applyCofficeFont(font: .body2Medium)
                    .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                  Text(cafe.isOpened ?? false ? "영업중" : "영업종료")
                    .applyCofficeFont(font: .button)
                    .foregroundColor(Color(asset: CofficeAsset.Colors.secondary1))
                  Text("월: 11:00 ~ 23:00")
                    .applyCofficeFont(font: .body1Medium)
                    .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
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
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 0) {
                ForEach(1...10, id: \.self) { _ in
                  Image(uiImage: CofficeAsset.Asset.cafeImage.image)
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
                .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
                .applyCofficeFont(font: .body2Medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(
                      Color(asset: CofficeAsset.Colors.grayScale3),
                      lineWidth: 1
                    )
                )
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
          .padding(.horizontal, 20)
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
      ),
      cafe: Cafe.dummy
    )
  }
}
