//
//  SavedListView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct SavedListView: View {
  let store: StoreOf<SavedList>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Group {
        if viewStore.shouldShowEmptyListReplaceView {
          emptyListReplaceView
        } else {
          mainView
        }
      }
      .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
      .onAppear {
        viewStore.send(.onAppear)
      }
      .onDisappear {
        viewStore.send(.onDisappear)
      }
      .customNavigationBar {
        Text(viewStore.title)
          .applyCofficeFont(font: .header1)
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 20)
          .padding(.vertical, 12)
      }
      .popup(
        item: viewStore.binding(
          get: \.toastMessage,
          send: { .set(\.$toastMessage, $0) }
        ),
        itemView: { message in
          ToastView(
            title: message,
            image: CofficeAsset.Asset.checkboxCircleFill18px,
            config: ToastConfiguration.default
          )
          .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
        },
        customize: {
          $0
            .type(.floater(verticalPadding: 16, horizontalPadding: 0, useSafeAreaInset: true))
            .autohideIn(2)
            .closeOnTap(true)
            .closeOnTapOutside(true)
        }
      )
    }
  }

  var mainView: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
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
                if cafe.isValidImageUrl {
                  thumbnailImageView(cafe: cafe, proxy: proxy)
                } else {
                  CofficeAsset.Colors.grayScale2.swiftUIColor
                    .frame(
                      width: (proxy.size.width - 60) / 2,
                      height: (proxy.size.width - 60) / 2
                    )
                    .overlay(
                      alignment: .center,
                      content: {
                        CofficeAsset.Asset.icPlaceholder.swiftUIImage
                          .resizable()
                          .frame(width: 44, height: 44)
                      }
                    )
                    .overlay(alignment: .topTrailing) {
                      bookmarkButton(cafe: cafe)
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
        .refreshable { @MainActor in
          viewStore.send(.fetchMyPlaces)
        }
      }
    }
  }

  private func thumbnailImageView(cafe: Cafe, proxy: GeometryProxy) -> some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      LinearGradient(
        gradient: Gradient(colors: [.black.opacity(0.06), .black.opacity(0.3)]),
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(
        width: (proxy.size.width - 60) / 2,
        height: (proxy.size.width - 60) / 2
      )
      .overlay(alignment: .topTrailing) {
        bookmarkButton(cafe: cafe)
      }
      .background(alignment: .center) {
        KFImage.url(URL(string: cafe.imageUrls?.first ?? ""))
          .onFailureImage(CofficeAsset.Asset.savedListFailImagePlaceholder.image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(
            width: (proxy.size.width - 60) / 2,
            height: (proxy.size.width - 60) / 2
          )
          .background(CofficeAsset.Colors.grayScale2.swiftUIColor)
          .clipped()
          .cornerRadius(5)
      }
    }
  }

  private func bookmarkButton(cafe: Cafe) -> some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
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
        reducer: {
          SavedList()
        }
      )
    )
  }
}
