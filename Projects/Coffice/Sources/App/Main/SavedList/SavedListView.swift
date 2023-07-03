//
//  SavedListView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SavedListView: View {
  let store: StoreOf<SavedList>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      GeometryReader { proxy in
        ScrollView(.vertical) {
          LazyVGrid(
            columns: [
              GridItem(.flexible(), spacing: 20),
              GridItem(.flexible(), spacing: 20)
            ],
            alignment: .center,
            spacing: 24
          ) {
            ForEach((0...30), id: \.self) { _ in
              VStack(spacing: 0) {
                CofficeAsset.Asset.cafeImage.swiftUIImage
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(
                    width: (proxy.size.width - 60) / 2,
                    height: (proxy.size.width - 60) / 2
                  )
                  .clipped()
                  .cornerRadius(5)
                  .overlay(alignment: .topTrailing) {
                    Button {
                      debugPrint("저장화면 bookmark tapped")
                    } label: {
                      CofficeAsset.Asset.bookmarkLine40px.swiftUIImage
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
                        .frame(width: 40, height: 40)
                    }
                  }
                Text("카페 이름")
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .applyCofficeFont(font: .header3)
                  .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                  .padding(.top, 16)
                Text("카페 주소")
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .applyCofficeFont(font: .body2Medium)
                  .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                  .padding(.top, 4)
              }
            }
          }
          .padding(.horizontal, 20)
          .customNavigationBar {
            HStack(spacing: 4) {
              Text(viewStore.title)
                .applyCofficeFont(font: .header1)
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
              CofficeAsset.Asset.bookmarkFill40px.swiftUIImage
                .frame(width: 36, height: 36)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .padding(.vertical, 14)
          }
        }
      }
    }
  }
}

struct SavedListView_Previews: PreviewProvider {
  static var previews: some View {
    SavedListView(
      store: .init(
        initialState: .init(),
        reducer: SavedList()
      )
    )
  }
}
