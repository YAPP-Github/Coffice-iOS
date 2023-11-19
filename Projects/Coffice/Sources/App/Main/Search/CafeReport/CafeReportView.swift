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
          cafeSearchButton
          mandatoryOptionView
        }
        .padding(.horizontal, 16)
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
        .popup(
          item: viewStore.$cafeReportSearchState,
          itemView: { viewState in
            CafeReportSearchView(
              store: store.scope(
                state: { _ in viewState },
                action: CafeReport.Action.cafeReportSearch
              )
            )
          },
          customize: BottomSheetContent.customize
        )
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
    )
  }
}

extension CafeReportView {
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

  var cafeSearchButton: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        Button {
          viewStore.send(.cafeSearchButtonTapped)
        } label: {
          HStack(spacing: 12) {
            CofficeAsset.Asset.searchLine24px.swiftUIImage
              .renderingMode(.template)
              .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
              .padding(.leading, 12)
            Text("카페명 검색")
              .applyCofficeFont(font: .subtitle1Medium)
              .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
            Spacer()
          }
          .background(
            CofficeAsset.Colors.grayScale2.swiftUIColor
              .frame(height: 48)
              .cornerRadius(8)
          )
          .frame(height: 48)
        }
        .padding(.bottom, 36)
      }
    )
  }

  var mandatoryOptionView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          Text("작업하기 좋은 공간이었나요?")
            .applyCofficeFont(font: .header2)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 24)
            .padding(.bottom, 32)
        }
        .padding(.top, 16)
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
