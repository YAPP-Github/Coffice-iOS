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
import PopupView

struct CafeMapView: View {
  let store: StoreOf<CafeMapCore>
  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        GeometryReader { geometry in
          ZStack {
            NaverMapView(
              store: store.scope(
                state: \.naverMapState,
                action: CafeMapCore.Action.naverMapAction
              )
            )
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
              .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
              .frame(width: geometry.size.width, height: geometry.size.height)
              .zIndex(1)
            }

            VStack(alignment: .center, spacing: 0) {
              headerView
                .contentShape(Rectangle())
                .onTapGesture { viewStore.send(.updateDisplayType(.searchView)) }
                .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
                .padding(.bottom, 24)
              if viewStore.naverMapState.shouldShowRefreshButtonView {
                refreshButtonView
              }
              Spacer()
              bottomFloatingButtonView
                .padding(.trailing, 24)
              
              if viewStore.naverMapState.selectedCafe != nil {
                CafeCardView(store: store)
                  .frame(width: geometry.size.width)
                  .onTapGesture { viewStore.send(.cardViewTapped) }
              }
            }
            .frame(
              width: geometry.size.width,
              height: geometry.size.height
            )
          }
          .ignoresSafeArea(.keyboard)
          .padding(.bottom, 20)
          .onAppear {
            if geometry.size.width == 0 {
              viewStore.send(.updateMaxScreenWidth(UIScreen.main.bounds.width))
            } else {
              viewStore.send(.updateMaxScreenWidth(geometry.size.width))
            }
          }
        }
        .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
        .navigationBarHidden(true)
        .onAppear { viewStore.send(.onAppear) }
        .popup(
          item: viewStore.binding(
            get: \.serviceAreaPopupState,
            send: { .set(\.$serviceAreaPopupState, $0) }
          )
        ) { viewState in
          ServiceAreaPopupView(
            store: store.scope(
              state: { _ in viewState },
              action: CafeMapCore.Action.serviceAreaPopupAction
            )
          )
        } customize: {
          $0
            .backgroundColor(.black.opacity(0.4))
            .isOpaque(true)
            .closeOnTap(false)
            .dragToDismiss(false)
        }
        .popup(isPresented: viewStore.$shouldShowToast) {
          ToastView(
            title: viewStore.toastType.title,
            image: viewStore.toastType.image,
            config: ToastConfiguration.default
          )
          .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
        } customize: {
          $0
            .type(.floater(verticalPadding: 16, horizontalPadding: 0, useSafeAreaInset: true))
            .autohideIn(2)
            .closeOnTap(true)
            .closeOnTapOutside(true)
        }
      }
    )
  }
}

extension CafeMapView {
  var refreshButtonView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        Button {
          viewStore.send(.naverMapAction(.refreshButtonTapped))
        } label: {
          HStack(spacing: 8) {
            CofficeAsset.Asset.refresh18px.swiftUIImage
              .renderingMode(.template)
              .resizable()
              .frame(width: 18, height: 18)
              .scaledToFill()
              .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
            Text("현위치 재검색")
              .applyCofficeFont(font: .body1Medium)
              .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
          }
          .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 16))
        }
        .background {
          RoundedRectangle(cornerRadius: 22)
            .foregroundColor(CofficeAsset.Colors.secondary0.swiftUIColor)
        }
      }
    )
  }

  var bottomFloatingButtonView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        HStack(spacing: 0) {
          Spacer()
          VStack(spacing: 16) {
            ForEach(viewStore.naverMapState.bottomFloatingButtons, id: \.self) { floatingButton in
              Button {
                viewStore.send(.naverMapAction(.bottomFloatingButtonTapped(floatingButton.type)))
              } label: {
                floatingButton.image
                  .frame(width: 48, height: 48)
              }
            }
          }
        }
        .padding(.bottom, 24)
      }
    )
  }

  var headerView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          searchDescriptionView
          orderFilterView
            .padding(.leading, 20)
        }
      }
    )
  }

  var searchDescriptionView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
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
    )
  }

  var orderFilterView: some View {
    CafeFilterMenusView(
      store: store.scope(
        state: \.cafeFilterMenusState,
        action: CafeMapCore.Action.cafeFilterMenusAction
      )
    )
    .padding(.top, 8)
  }
}

struct CafeMapView_Previews: PreviewProvider {
  static var previews: some View {
    CafeMapView(
      store: .init(
        initialState: .init(),
        reducer: {
          CafeMapCore()
        }
      )
    )
  }
}
