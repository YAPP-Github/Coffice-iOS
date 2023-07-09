//
//  CafeSearchDetailHeaderView.swift
//  coffice
//
//  Created by Min Min on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct CafeSearchDetailHeaderView: View {
  private let store: StoreOf<CafeSearchDetail>

  init(store: StoreOf<CafeSearchDetail>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        // TODO: 이미지 여러장 들어오는 경우 스크롤 필요
        if let imageUrl = viewStore.cafe?.imageUrls?.first {
          KFImage.url(URL(string: imageUrl))
            .resizable()
            .frame(height: 200 + (UIApplication.keyWindow?.safeAreaInsets.top ?? 0))
            .scaledToFit()
        } else {
          Image("cafeImage")
            .resizable()
            .frame(height: 200 + (UIApplication.keyWindow?.safeAreaInsets.top ?? 0))
            .scaledToFit()
        }

        VStack(spacing: 0) {
          HStack {
            VStack(spacing: 0) {
              Text("카페")
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .button)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
              Text(viewStore.cafe?.name ?? "훅스턴")
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .header0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 36)
                .padding(.top, 8)
              Text(viewStore.cafe?.address?.address ?? "서울 서대문구 연희로 91 2층")
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                .applyCofficeFont(font: .body1Medium)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
                .padding(.top, 4)
            }

            VStack {
              CofficeAsset.Asset.bookmarkLine40px.swiftUIImage
              Spacer()
            }
          }

          HStack(spacing: 8) {
            Text("영업중")
              .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
              .applyCofficeFont(font: .button)
              .frame(alignment: .leading)
            Text("목 09:00 ~ 21:00")
              .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
              .applyCofficeFont(font: .body1Medium)
            Spacer()
          }
          .padding(.top, 16)

          Divider()
            .padding(.top, 20)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 16, trailing: 20))
      }
    }
  }
}
