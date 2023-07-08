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
        ZStack {
          NaverMapView(viewStore: viewStore)
            .ignoresSafeArea()
          ZStack {
            switch viewStore.displayViewType {
            case .searchResultView:
              CafeSearchListView(store: store.scope(
                state: \.cafeSearchListState,
                action: CafeMapCore.Action.cafeSearchListAction)
              )
              .zIndex(1)

            case .mainMapView:
              Group {
                if viewStore.selectedCafe != nil {
                  VStack {
                    Spacer()
                    CafeCardView(store: store)
                      .frame(width: geometry.size.width, height: 260)
                      .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
                  }
                } else {
                  EmptyView()
                }
              }

            case .searchView:
              CafeSearchView(store: store.scope(
                state: \.cafeSearchState,
                action: CafeMapCore.Action.cafeSearchAction)
              )
              .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
              .zIndex(1)
            }
            VStack(alignment: .trailing, spacing: 0) {
              header
                .onTapGesture { viewStore.send(.updateDisplayType(.searchView)) }
                .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
              floatingButtonView
                .padding()
              Spacer()
              if viewStore.isSelectedCafe {
                CafeCardView(store: store)
                  .frame(height: 260)
                  .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
              }
            }
          }
          .navigationBarHidden(true)
        }
        .onAppear {
          viewStore.send(.requestLocationAuthorization)
        }
      }
      .ignoresSafeArea(.keyboard)
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

  var header: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        searchTextField
        orderFilterView
      }
    }
  }

  var searchTextField: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        TextField(
          "🔍  지역, 지하철로 검색",
          text: viewStore.binding(\.$searchText)
        )
        .textFieldStyle(.plain)
        .applyCofficeFont(font: .subtitle1Medium)
        .frame(height: 35)
        .padding(.leading, 5)
        .padding(.trailing, 25)
        .overlay {
          RoundedRectangle(cornerRadius: 5)
            .stroke(.gray, lineWidth: 1)
        }
        .onSubmit {
        }

        HStack {
          Spacer()
          Button {
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.gray)
              .padding(.trailing, 5)
          }
        }
      }
      .padding(.horizontal, 16)
    }
  }

  var orderFilterView: some View {
    CafeFilterMenusView(
      store: store.scope(
        state: \.cafeFilterMenusState,
        action: CafeMapCore.Action.cafeFilterMenus(action:)
      )
    )
    .padding(.top, 16)
  }
}
