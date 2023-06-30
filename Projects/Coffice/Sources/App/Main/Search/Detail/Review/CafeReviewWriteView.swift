//
//  CafeReviewWriteView.swift
//  coffice
//
//  Created by Min Min on 2023/06/29.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeReviewWriteView: View {
  let store: StoreOf<CafeReviewWrite>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        HStack {
          Text("리뷰 쓰기")
            .applyCofficeFont(font: .header1)
            .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale9))
            .padding(.vertical, 4)
          Spacer()
          Button {
            viewStore.send(.dismissView)
          } label: {
            Image(asset: CofficeAsset.Asset.close40px)
          }
        }
        .padding(.top, 24)
        .padding(.bottom, 16)

        HStack {
          Image(asset: CofficeAsset.Asset.cafeImage)
            .resizable()
            .frame(width: 48, height: 48)
            .padding(.top, 4)

          VStack {
            Text("훅스턴")
              .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale9))
              .applyCofficeFont(font: .subtitleSemiBold)
              .frame(maxWidth: .infinity, alignment: .leading)
            Text("서울 서대문구 연희로 91 2층")
              .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
              .applyCofficeFont(font: .body1Medium)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding(.bottom, 16)

        Divider()
          .background(Color(asset: CofficeAsset.Colors.grayScale3))
          .frame(height: 1)

        reviewFormScrollView

        VStack(alignment: .center) {
          Button {
            // TODO: 등록, 수정하기 버튼 이벤트 구현 필요
          } label: {
            Text("등록하기")
              .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale1))
              .applyCofficeFont(font: .button)
              .frame(maxWidth: .infinity)
          }
          .disabled(viewStore.isSaveButtonEnabled.isFalse)
        }
        .frame(height: 44)
        .background(Color(asset: viewStore.saveButtonBackgroundColorAsset))
        .cornerRadius(4, corners: .allCorners)
      }
      .padding(.horizontal, 20)
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

extension CafeReviewWriteView {
  var reviewFormScrollView: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack(spacing: 0) {
        reviewOptionMenuView
        reviewTextView
      }
    }
  }

  var reviewOptionMenuView: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        ForEach(viewStore.optionButtonStates.indices, id: \.self) { buttonIndex in
          CafeReviewOptionButtonsView(
            store: store.scope(
              state: \.optionButtonStates[buttonIndex],
              action: CafeReviewWrite.Action.optionButtonsAction
            )
          )
        }
      }
    }
  }

  var reviewTextView: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 0) {

      }
    }
  }
}

struct CafeReviewWriteView_Previews: PreviewProvider {
  static var previews: some View {
    CafeReviewWriteView(
      store: .init(
        initialState: .mock,
        reducer: CafeReviewWrite()
      )
    )
  }
}
