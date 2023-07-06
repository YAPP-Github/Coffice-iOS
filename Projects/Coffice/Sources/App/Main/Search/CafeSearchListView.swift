//
//  CafeSearchView.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchListView: View {
  let store: StoreOf<CafeSearchListCore>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        headerView
          .padding(EdgeInsets(top: 0, leading: 20, bottom: 16, trailing: 16))
          .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
        switch viewStore.viewType {
        case .listView:
          ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
              ForEach(0..<viewStore.cafeList.count, id: \.self) { index in
                CafeSearchListCell(store: store, cafe: viewStore.state.cafeList[index])
                  .onTapGesture { }
                  .padding(.bottom, 40)
              }
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
          }
          .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
        case .mapView:
          Spacer()
        }
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}

extension CafeSearchListView {
  var headerView: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 8) {
        headLine
        filterButtons
      }
      .navigationBarHidden(true)
    }
  }

  var headLine: some View {
    WithViewStore(store) { viewStore in
        HStack(spacing: 0) {
          Button {
            viewStore.send(.backbuttonTapped)
          } label: {
            CofficeAsset.Asset.arrowLeftTopbarLine24px.swiftUIImage
              .resizable()
              .frame(width: 24, height: 24)
          }
          .padding(.trailing, 12)
          Text(viewStore.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .onTapGesture { viewStore.send(.titleLabelTapped) }
          Button {
            if viewStore.viewType == .mapView {
              viewStore.send(.updateViewType(.listView))
            } else {
              viewStore.send(.updateViewType(.mapView))
            }
          } label: {
            switch viewStore.viewType {
            case .mapView:
              CofficeAsset.Asset.list24px.swiftUIImage
            case .listView:
              CofficeAsset.Asset.mapLine24px.swiftUIImage
            }
          }
          .padding(.trailing, 20)
      }
      .frame(height: 48)
    }
  }

  var filterButtons: some View {
    WithViewStore(store) { viewStore in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(viewStore.filterOrders, id: \.self) { filter in
            Button {
              viewStore.send(.filterButtonTapped(filter))
            } label: {
              if filter == .detail {
                Image(asset: CofficeAsset.Asset.filterLine24px)
                  .resizable()
                  .renderingMode(.template)
                  .frame(width: 24, height: 24)
                  .scaledToFit()
                  .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                  .frame(width: filter.size.width, height: filter.size.height)
                  .overlay(
                    RoundedRectangle(cornerRadius: 18)
                      .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
                  )
              } else {
                HStack(alignment: .center, spacing: 0) {
                  Text(filter.title)
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                    .applyCofficeFont(font: .body1Medium)
                  Image(asset: CofficeAsset.Asset.arrowDropDownLine18px)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 18, height: 18)
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                }
                .frame(width: filter.size.width, height: filter.size.height)
                .overlay(
                  RoundedRectangle(cornerRadius: 18)
                    .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
                )
              }
            }
            .cornerRadius(18)
          }
        }
      }
      .frame(width: 355, height: 36)
    }
  }
}
