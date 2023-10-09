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
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          Text(viewStore.title)
            .foregroundColor(CofficeAsset.Colors.grayScale8.swiftUIColor)
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
                    .foregroundColor(viewState.textColorAsset.swiftUIColor)
                    .applyCofficeFont(font: .body2Medium)
                    .cornerRadius(18)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(viewState.backgroundColorAsset.swiftUIColor.clipShape(Capsule()))
                    .overlay {
                      RoundedRectangle(cornerRadius: 18)
                        .stroke(viewState.borderColorAsset.swiftUIColor, lineWidth: 1)
                        .padding(1)
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
    )
  }
}

struct CafeReviewOptionButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    CafeReviewOptionButtonsView(
      store: .init(
        initialState: .mock,
        reducer: {
          CafeReviewOptionButtons()
        }
      )
    )
    .previewLayout(.sizeThatFits)
  }
}
