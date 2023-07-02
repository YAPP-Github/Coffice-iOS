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
        ScrollView(.vertical, showsIndicators: false) {
          LazyVStack(spacing: 0) {
            ForEach(1...10, id: \.self) { idx in
              CafeCardView(viewType: .listCell)
                .onAppear { viewStore.send(.scrollAndLoadData(idx)) }
                .padding(.bottom, 40)
            }
          }
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
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
    }
  }

  var headLine: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 0) {
        HStack(spacing: 12) {
          Button {
            // TODO: 버튼 클릭 시, 초기 지도화면으로 이동
          } label: {
            CofficeAsset.Asset.arrowLeftTopbarLine24px.swiftUIImage
              .resizable()
              .frame(width: 24, height: 24)
          }
          Text("SearchKeyWord")
          Spacer()
        }
        .frame(width: 280, height: 48)
        Spacer()
        Button {
        // TODO: 버튼 클릭 시, 하단 리스트 뷰 -> 마커 찍혀 있는 지도뷰
        } label: {
          CofficeAsset.Asset.mapLine24px.swiftUIImage
            .resizable()
            .frame(width: 24, height: 24)
        }
      }
      .frame(width: 335, height: 48)
    }
  }

  var filterButtons: some View {
    WithViewStore(store) { store in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(store.filterOrders, id: \.self) { filter in
            Button {
              store.send(.filterButtonTapped(filter))
            } label: {
              if filter == .detail {
                    Image(asset: CofficeAsset.Asset.filterLine24px)
                      .resizable()
                      .renderingMode(.template)
                      .frame(width: 24, height: 24)
                      .scaledToFit()
                      .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
                      .frame(width: filter.size.width, height: filter.size.height)
                      .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(asset: CofficeAsset.Colors.grayScale4), lineWidth: 1)
                         )
              } else {
                HStack(alignment: .center, spacing: 0) {
                  Text(filter.title)
                    .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
                    .applyCofficeFont(font: .body1Medium)
                  Image(asset: CofficeAsset.Asset.arrowDropDownLine18px)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
                }
                .frame(width: filter.size.width, height: filter.size.height)
                .overlay(
                       RoundedRectangle(cornerRadius: 18)
                           .stroke(Color(asset: CofficeAsset.Colors.grayScale4), lineWidth: 1)
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
