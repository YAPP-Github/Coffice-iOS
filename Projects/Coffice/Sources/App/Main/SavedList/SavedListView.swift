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
    WithViewStore(store) { viewStore in
      Group {
        if viewStore.shouldShowEmptyListReplaceView {
          emptyListReplaceView
        } else {
          mainView
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
      .onDisappear {
        viewStore.send(.onDisappear)
      }
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
            ForEach(viewStore.cafes, id: \.self) { cafe in
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
                      viewStore.send(.bookmarkButtonTapped(cafe: cafe))
                    } label: {
                      (
                        cafe.isBookmarked
                        ? CofficeAsset.Asset.bookmarkFill40px.swiftUIImage
                        : CofficeAsset.Asset.bookmarkLine40px.swiftUIImage
                      )
                      .resizable()
                      .renderingMode(.template)
                      .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
                      .frame(width: 40, height: 40)
                      .opacity(0.8)
                    }
                  }
                Text(cafe.name)
                  .lineLimit(1)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .applyCofficeFont(font: .header3)
                  .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                  .padding(.top, 16)
                Text(cafe.address?.address ?? "")
                  .lineLimit(1)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .applyCofficeFont(font: .body2Medium)
                  .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                  .padding(.top, 4)
              }
              .onTapGesture {
                viewStore.send(.pushCafeDetail(cafeId: cafe.placeId))
              }
            }
          }
          .padding(.horizontal, 20)
        }
        .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
      }
    }
  }

  private var emptyListReplaceView: some View {
    VStack(alignment: .center) {
      Text("아직 저장된 공간이 없어요")
        .applyCofficeFont(font: .header2)
        .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
      Text("작업하고 싶은 공간을 저장해보세요")
        .applyCofficeFont(font: .subtitle1Medium)
        .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
        .padding(.top, 12)
    }
    .frame(maxHeight: .infinity)
    .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
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
