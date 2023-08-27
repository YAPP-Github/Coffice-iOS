//
//  UserReviewCell.swift
//  coffice
//
//  Created by Min Min on 2023/07/28.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct UserReviewCell: View {
  private let store: StoreOf<CafeDetailMenuReducer>
  private let viewState: UserReviewCellState

  init(store: StoreOf<CafeDetailMenuReducer>, viewState: UserReviewCellState) {
    self.store = store
    self.viewState = viewState
  }

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        VStack(spacing: 0) {
          HStack {
            VStack {
              CofficeAsset.Asset.userProfile40px.swiftUIImage
              Spacer()
            }

            VStack(spacing: 4) {
              Text(viewState.userName)
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .subtitleSemiBold)
                .frame(maxWidth: .infinity, alignment: .leading)
              Text(viewState.dateDescription)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                .applyCofficeFont(font: .body2Medium)
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
            }

            Spacer()

            VStack {
              if viewState.isMyReview {
                Button {
                  viewStore.send(.reviewModifyButtonTapped(viewState: viewState))
                } label: {
                  Text("수정/삭제")
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                    .applyCofficeFont(font: .body2Medium)
                }
              } else {
                Button {
                  viewStore.send(.reviewReportButtonTapped(viewState: viewState))
                } label: {
                  CofficeAsset.Asset.more2Fill24px.swiftUIImage
                }
              }
              Spacer()
            }
          }
        }
        .frame(height: 42)
        .padding(.top, 20)

        Text(viewState.content)
          .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
          .applyCofficeFont(font: .body1)
          .multilineTextAlignment(.leading)
          .padding(.top, 20)

        // TODO: Tag가 한줄 넘어갈 경우 넘어가도록 커스텀 뷰 구현 필요
        if viewState.reviewTagTitles.isNotEmpty {
          HStack(spacing: 8) {
            ForEach(viewState.reviewTagTitles, id: \.self) { tagTitle in
              Text(tagTitle)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                .applyCofficeFont(font: .body2Medium)
                .frame(height: 18)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .overlay(
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(
                      CofficeAsset.Colors.grayScale4.swiftUIColor,
                      lineWidth: 1
                    )
                )
            }
          }
          .frame(height: 26)
          .padding(.top, 20)
        }

        CofficeAsset.Colors.grayScale3.swiftUIColor
          .frame(height: 1)
          .padding(.top, 16)
          .hiddenWithOpacity(isHidden: viewState == viewStore.userReviewCellStates.last)
      }
    }
  }
}
