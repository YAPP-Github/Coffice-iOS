//
//  CafeMapView.swift
//  Cafe
//
//  Created by sehooon on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import NMapsMap
import SwiftUI

struct CafeMapView: View {
  let store: StoreOf<CafeMapCore>
  var body: some View {
    WithViewStore(store) { viewStore in
      GeometryReader { geometry in
        ZStack(alignment: .center) {
          NaverMapView(viewStore: viewStore)
            .ignoresSafeArea()

          switch viewStore.displayViewType {
          case .searchResultView:
            CafeSearchListView(store: store.scope(
              state: \.cafeSearchListState,
              action: CafeMapCore.Action.cafeSearchListAction)
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
            .zIndex(1)

          case .mainMapView:
            Color.clear

          case .searchView:
            CafeSearchView(store: store.scope(
              state: \.cafeSearchState,
              action: CafeMapCore.Action.cafeSearchAction)
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
            .zIndex(1)
          }

          VStack(spacing: 0) {
            header
              .onTapGesture { viewStore.send(.updateDisplayType(.searchView)) }
              .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
              .zIndex(1)
            }
            VStack(alignment: .trailing, spacing: 0) {
              headerView
                .onTapGesture { viewStore.send(.updateDisplayType(.searchView)) }
                .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
              floatingButtonView
                .padding()
            HStack(spacing: 0) {
              Spacer()
              floatingButtonView
                .padding(.vertical)
            }
            Spacer()
            floatingTestButtonView
            if viewStore.selectedCafe != nil {
              CafeCardView(store: store, screendWidth: geometry.size.width)
                .frame(width: geometry.size.width)
                .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
            }
          }
        }
      }
      .navigationBarHidden(true)
      .onAppear {
        viewStore.send(.requestLocationAuthorization)
      }
      .onDisappear {
        viewStore.send(.onDisappear)
      }
    }
  }
}

extension CafeMapView {
  var floatingButtonView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 10) {
        ForEach(viewStore.floatingButtons, id: \.self) { floatingButton in
          Button {
            viewStore.send(.floatingButtonTapped(floatingButton))
          } label: {
            Circle()
              .foregroundColor(.white)
              .shadow(color: .gray, radius: 2, x: 0, y: 2)
              .overlay {
                Image(systemName: floatingButton.image)
              }
              .frame(width: 50, height: 50)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  @available(*, deprecated, message: "테스트용 UI로, 상제 리스트뷰 진입점 추가 후 제거 예정")
  var floatingTestButtonView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()

        HStack {
          Button {
            viewStore.send(.pushToSearchDetailForTest(cafeId: 1))
          } label: {
            ZStack(alignment: .center) {
              Circle()
                .foregroundColor(.white)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .frame(width: 48, height: 48)
              Text("검색상세")
                .applyCofficeFont(font: .button)
            }
          }
          .buttonStyle(.plain)
          Spacer()
        }
        .padding(.leading, 24)
        .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height + 24)
      }
    }
  }

  var headerView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        searchDescriptionView
        orderFilterView
      }
    }
  }

  var searchDescriptionView: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 12) {
        CofficeAsset.Asset.searchLine24px.swiftUIImage
          .padding(.vertical, 12)
        Text("지하철, 카페 이름으로 검색")
          .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
          .applyCofficeFont(font: .subtitle1Medium)
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(height: 20)
          .padding(.vertical, 14)
      }
      .padding(.horizontal, 20)
    }
  }

  var orderFilterView: some View {
    CafeFilterMenusView(
      store: store.scope(
        state: \.cafeFilterMenusState,
        action: CafeMapCore.Action.cafeFilterMenus(action:)
      )
    )
    .padding(.top, 8)
  }
}
