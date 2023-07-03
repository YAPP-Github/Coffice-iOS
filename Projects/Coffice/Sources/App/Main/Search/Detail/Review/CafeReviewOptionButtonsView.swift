//
//  CafeReviewOptionButtonsView.swift
//  coffice
//
//  Created by Min Min on 2023/06/30.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeReviewOptionButtonsView: View {
  let store: StoreOf<CafeReviewOptionButtons>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        Text(viewStore.title)
          .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale8))
          .applyCofficeFont(font: .button)
          .frame(height: 20)
          .frame(maxWidth: .infinity, alignment: .leading)
        ScrollView(.horizontal) {
          HStack(spacing: 8) {
            ForEach(viewStore.optionButtonViewStates.indices, id: \.self) { viewStateIndex in
              let viewState = viewStore.optionButtonViewStates[viewStateIndex]

              Button {
                viewStore.send(.optionButtonTapped(optionType: viewState.optionType, index: viewStateIndex))
              } label: {
                Text(viewState.title)
                  .foregroundColor(Color(asset: viewState.textColorAsset))
                  .applyCofficeFont(font: .body2Medium)
                  .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                  .background(Color(asset: viewState.backgroundColorAsset).clipShape(Capsule()))
                  .overlay {
                    RoundedRectangle(cornerRadius: 18)
                      .stroke(Color(asset: viewState.borderColorAsset), lineWidth: 1)
                  }
                  .frame(height: 34)
                  .padding(.leading, 1)
              }
            }
          }
        }
        .padding(.top, 16)
      }
      .frame(height: 70)
      .padding(.top, 20)
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

struct CafeReviewOptionButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    CafeReviewOptionButtonsView(
      store: .init(
        initialState: .mock,
        reducer: CafeReviewOptionButtons()
      )
    )
    .previewLayout(.sizeThatFits)
  }
}
