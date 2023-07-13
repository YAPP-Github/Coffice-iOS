//
//  CafeSearchDetailView.swift
//  coffice
//
//  Created by Min Min on 2023/06/24.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchDetailView: View {
  private let store: StoreOf<CafeSearchDetail>

  init(store: StoreOf<CafeSearchDetail>) {
    self.store = store
  }

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        ScrollView(.vertical) {
          VStack(spacing: 0) {
            CafeSearchDetailHeaderView(store: store)
            CafeSearchDetailSubInfoView(store: store)
            CafeSearchDetailMenuView(store: store)
          }
        }
      }
      .navigationBarHidden(true)
      .ignoresSafeArea(.all, edges: .top)
      .overlay(
        alignment: .top,
        content: {
          HStack {
            Button {
              viewStore.send(.popView)
            } label: {
              CofficeAsset.Asset.arrowLeftSLine40px.swiftUIImage
                .renderingMode(.template)
                .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
            }

            Spacer()

            Button {
              // TODO: 공유하기 기능 추가 필요
            } label: {
              CofficeAsset.Asset.shareBoxFill40px.swiftUIImage
                .renderingMode(.template)
                .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
            }
          }
          .padding(.top, 4)
          .padding(.horizontal, 8)
        }
      )
      .onAppear {
        viewStore.send(.onAppear)
      }
      .sheet(
        item: viewStore.binding(\.$cafeReviewWriteState),
        content: { viewState in
          CafeReviewWriteView(
            store: store.scope(
              state: { _ in viewState },
              action: CafeSearchDetail.Action.cafeReviewWrite(action:)
            )
          )
        }
      )
    }
  }
}

struct CafeSearchDetailView_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchDetailView(
      store: .init(
        initialState: .init(cafeId: 1),
        reducer: CafeSearchDetail()
      )
    )
  }
}
