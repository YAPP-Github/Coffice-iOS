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
          .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
        switch viewStore.viewType {
        case .listView:
          ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
              ForEach(viewStore.cafeList.indices, id: \.self) { index in
                CafeSearchListCell(store: store, cafe: viewStore.cafeList[index])
                  .onAppear { viewStore.send(.scrollAndLoadData(index)) }
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
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}

extension CafeSearchListView {
  var headerView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 8) {
        headLine
        filterMenusView
      }
      .padding(.horizontal, 20)
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
          .contentShape(Rectangle())
          .onTapGesture { viewStore.send(.titleLabelTapped) }
          .lineLimit(1)
        Spacer()
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
      }
      .frame(height: 48)
    }
  }

  var filterMenusView: some View {
    CafeFilterMenusView(
      store: store.scope(
        state: \.filterMenusState,
        action: CafeSearchListCore.Action.filterMenus(action:)
      )
    )
  }
}

struct CafeSearchListView_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchListView(store: .init(
      initialState: .init(filterBottomSheetState: .mock),
      reducer: CafeSearchListCore()
    ))
  }
}
