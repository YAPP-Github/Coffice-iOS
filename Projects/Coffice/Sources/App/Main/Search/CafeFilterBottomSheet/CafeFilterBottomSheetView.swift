//
//  CafeFilterBottomSheetView.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeFilterBottomSheetView: View {
  private let store: StoreOf<CafeFilterBottomSheet>

  init(store: StoreOf<CafeFilterBottomSheet>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          filterOptionButtonContainerView
          footerView
        }
        .background(
          CofficeAsset.Colors.grayScale1.swiftUIColor
            .cornerRadius(18, corners: [.topLeft, .topRight])
        )
        .popup(
          item: viewStore.binding(
            get: \.bubbleMessageViewState,
            send: { .set(\.$bubbleMessageViewState, $0) }
          ),
          itemView: { viewState in
            BubbleMessageView(store: store.scope(
              state: { _ in viewState },
              action: CafeFilterBottomSheet.Action.bubbleMessageAction)
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

extension CafeFilterBottomSheetView {
  var headerView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        HStack(spacing: 0) {
          Text(viewStore.filterType.title)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .applyCofficeFont(font: .header1)
            .frame(height: 32)
            .padding(.top, 28)
            .padding(.bottom, 20)
          if viewStore.shouldShowGuideButton {
            Button {
              viewStore.send(.infoGuideButtonTapped)
            } label: {
              CofficeAsset.Asset.informationLine18px.swiftUIImage
                .renderingMode(.template)
                .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
                .padding(EdgeInsets(top: 35, leading: 8, bottom: 27, trailing: 0))
            }
          }

          Spacer()

          Button {
            viewStore.send(.delegate(.dismiss))
          } label: {
            CofficeAsset.Asset.close40px.swiftUIImage
              .padding(.top, 24)
              .padding(.bottom, 16)
          }
        }
        .frame(height: 80)
        .padding(.horizontal, 20)
      }
    )
  }

  var filterOptionButtonContainerView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          headerView
          mainScrollView
        }
      }
    )
  }

  var mainScrollView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        ScrollView(.vertical) {
          VStack(alignment: .leading, spacing: 0) {
            ForEach(viewStore.mainViewState.optionButtonCellViewStates) { cellViewState in
              let viewStates = cellViewState.viewStates
              if viewStore.shouldShowSubSectionView {
                Text(cellViewState.sectionTitle)
                  .applyCofficeFont(font: .header3)
                  .foregroundColor(CofficeAsset.Colors.grayScale8.swiftUIColor)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .frame(height: 20)
                  .padding(.bottom, 16)
              }

              if viewStates.isNotEmpty {
                HStack(spacing: 8) {
                  ForEach(viewStates) { viewState in
                    let option = viewState.option
                    Button {
                      viewStore.send(.optionButtonTapped(optionType: option))
                    } label: {
                      Text(viewState.buttonTitle)
                        .applyCofficeFont(font: .body1Medium)
                        .foregroundColor(viewState.foregroundColor.swiftUIColor)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .cornerRadius(16)
                        .background(viewState.backgroundColor.swiftUIColor.clipShape(Capsule()))
                        .cornerRadius(18)
                        .overlay {
                          RoundedRectangle(cornerRadius: 18)
                            .stroke(viewState.borderColor.swiftUIColor, lineWidth: 1)
                            .padding(1)
                        }
                        .frame(height: 36)
                    }
                  }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 36)
                .padding(.bottom, 36)
              } else {
                EmptyView()
              }
            }
          }
          .padding(.leading, 20)
        }
        .frame(height: viewStore.scrollViewHeight)
        .padding(.top, 20)
      }
    )
  }

  var footerView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        HStack(alignment: .center, spacing: 12) {
          Button {
            viewStore.send(.resetCafeFilterButtonTapped)
          } label: {
            Text("초기화")
              .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
              .applyCofficeFont(font: .button)
              .frame(maxWidth: .infinity, alignment: .center)
              .frame(height: 44)
              .overlay {
                RoundedRectangle(cornerRadius: 4)
                  .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
              }
          }
          
          Button {
            viewStore.send(.saveCafeFilterButtonTapped)
          } label: {
            Text("저장하기")
              .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
              .applyCofficeFont(font: .button)
              .frame(maxWidth: .infinity, alignment: .center)
              .frame(height: 44)
              .background(
                CofficeAsset.Colors.grayScale9.swiftUIColor
                  .frame(height: 44)
                  .cornerRadius(4, corners: .allCorners)
              )
          }
        }
        .frame(height: 84)
        .padding(.horizontal, 20)
        .padding(.bottom, UIApplication.keyWindow?.safeAreaInsets.bottom ?? 0)
      }
    )
  }
}

struct CafeFilterBottomSheetView_Previews: PreviewProvider {
  static var previews: some View {
    CafeFilterBottomSheetView(
      store: .init(
        initialState: .mock,
        reducer: {
          CafeFilterBottomSheet()
        }
      )
    )
  }
}
