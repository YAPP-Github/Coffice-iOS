//
//  CafeReportView.swift
//  coffice
//
//  Created by Min Min on 11/2/23.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeReportView: View {
  let store: StoreOf<CafeReport>

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          photoSelectionView
        }
        .customNavigationBar(
          centerView: {
            Text(viewStore.title)
          },
          leftView: {
            Button {
              viewStore.send(.popView)
            } label: {
              CofficeAsset.Asset.arrowLeftSLine40px.swiftUIImage
            }
          }
        )
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
    )
  }

  var photoSelectionView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .center) {
          Button {
            // TODO: 사진추가 기능 구현 필요
          } label: {
            VStack(spacing: 4) {
              CofficeAsset.Asset.plusCircle24px.swiftUIImage
              Text("사진 추가 (최대 8개)")
                .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
                .applyCofficeFont(font: .body2Medium)
            }
            .frame(width: 138, height: 110)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
                .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
            )
          }
        }
        .padding(.top, 39)
        .padding(.bottom, 40)
      }
    )
  }
}

struct CafeReportView_Previews: PreviewProvider {
  static var previews: some View {
    CafeReportView(
      store: Store(initialState: CafeReport.State()) {
        CafeReport()
      }
    )
  }
}
