//
//  CafeSearchDetailSubInfoView.swift
//  coffice
//
//  Created by Min Min on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeDetailSubInfoView: View {
  private let store: StoreOf<CafeDetailSubInfoReducer>

  init(store: StoreOf<CafeDetailSubInfoReducer>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            cafeSubPrimaryInfoView
            cafeSecondaryInfoView
          }
          .padding(.horizontal, 20)

          CofficeAsset.Colors.grayScale3.swiftUIColor
            .frame(height: 4)
            .padding(.top, 20)
        }
        .popup(
          item: viewStore.binding(
            get: \.bubbleMessageViewState,
            send: { .set(\.$bubbleMessageViewState, $0) }
          ),
          itemView: { viewState in
            BubbleMessageView(store: store.scope(
              state: { _ in viewState },
              action: CafeDetailSubInfoReducer.Action.bubbleMessageAction)
            )
          },
          customize: { popup in
            popup
              .type(.default)
              .position(.center)
              .animation(.easeIn(duration: 0))
              .isOpaque(true)
              .closeOnTapOutside(true)
              .backgroundColor(CofficeAsset.Colors.grayScale10.swiftUIColor.opacity(0.4))
          }
        )
      }
    )
  }
}

extension CafeDetailSubInfoView {
  private var cafeSubPrimaryInfoView: some View {
    WithViewStore(store, observe: \.subPrimaryInfoViewStates) { viewStore in
      VStack(alignment: .center, spacing: 0) {
        Text("카페정보")
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .applyCofficeFont(font: .header3)
          .frame(height: 20)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.top, 15)

        HStack(alignment: .center, spacing: 40) {
          ForEach(viewStore.state) { viewState in
            VStack(alignment: .trailing, spacing: 8) {
              HStack(alignment: .top, spacing: 0) {
                Image(viewState.iconName)
                  .resizable()
                  .frame(width: 44, height: 44)
                Button {
                  viewStore.send(
                    .infoGuideButtonTapped(
                      viewState.guideType
                    )
                  )
                } label: {
                  Image(asset: CofficeAsset.Asset.informationLine18px)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(CofficeAsset.Colors.grayScale4.swiftUIColor)
                    .frame(width: 18, height: 18)
                }
              }
              HStack(spacing: 8) {
                Text(viewState.title)
                  .foregroundColor(CofficeAsset.Colors.grayScale8.swiftUIColor)
                  .applyCofficeFont(font: .button)
                  .frame(height: 20)
                Text(viewState.description)
                  .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                  .applyCofficeFont(font: .body1Medium)
                  .frame(height: 20)
              }
              .fixedSize(horizontal: true, vertical: true)
            }
          }
          .padding(.top, 16)
        }
        .frame(width: 300)

        CofficeAsset.Colors.grayScale3.swiftUIColor
          .frame(height: 1)
          .padding(.top, 33)
      }
    }
  }

  private var cafeSecondaryInfoView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            VStack(spacing: 0) {
              ForEach(viewStore.subSecondaryInfoViewStates) { viewState in
                Text(viewState.title)
                  .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                  .applyCofficeFont(font: .button)
                  .frame(height: 20)
                  .frame(maxWidth: 50, alignment: .leading)
                  .padding(.bottom, 16)
              }
            }

            VStack(alignment: .leading, spacing: 0) {
              ForEach(viewStore.subSecondaryInfoViewStates) { viewState in
                HStack {
                  Text(viewState.description)
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                    .applyCofficeFont(font: .body1Medium)
                    .frame(alignment: .leading)

                  if viewState.type == .congestion {
                    // FIXME: 혼잡도 어떤식으로 나타낼지 정의 필요
                    //                  Text(viewState.congestionDescription)
                    //                    .foregroundColor(viewState.congestionLevel == .high ? .red : .black)
                    //                    .font(.system(size: 14))

                    Spacer()

                    Text(viewStore.updatedDateDescription)
                      .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                      .applyCofficeFont(font: .body2Medium)
                      .frame(alignment: .trailing)
                  }
                }
                .frame(height: 20)
                .padding(.bottom, 16)
              }
            }
          }
        }
        .padding(.top, 20)
      }
    )
  }
}

struct CafeSearchDetailSubInfoView_Previews: PreviewProvider {
  static var previews: some View {
    CafeDetailSubInfoView(
      store: .init(
        initialState: .init(),
        reducer: {
          CafeDetailSubInfoReducer()
        }
      )
    )
  }
}
