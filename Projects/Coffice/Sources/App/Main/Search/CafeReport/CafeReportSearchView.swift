//
//  CafeReportSearchView.swift
//  coffice
//
//  Created by Min Min on 11/18/23.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeReportSearchView: View {
  let store: StoreOf<CafeReportSearch>

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          HStack {
            Text("카페 검색")
            Spacer()
            Button {
              viewStore.send(.dismiss)
            } label: {
              CofficeAsset.Asset.close40px.swiftUIImage
            }
          }
          .padding(.horizontal, 20)

          Spacer()
        }
        .frame(
          height: UIScreen.main.bounds.height
          - (UIApplication.keyWindow?.safeAreaInsets.top ?? 0)
          - 108
        )
        .background(
          CofficeAsset.Colors.grayScale1.swiftUIColor
            .cornerRadius(18, corners: [.topLeft, .topRight])
        )
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
    )
  }
}

struct CafeReportSearchView_Previews: PreviewProvider {
  static var previews: some View {
    CafeReportSearchView(
      store: Store(initialState: CafeReportSearch.State()) {
        CafeReportSearch()
      }
    )
  }
}
