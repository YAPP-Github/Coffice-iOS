//
//  CafeReportView.swift
//  coffice
//
//  Created by Min Min on 11/2/23.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Kingfisher
import PhotosUI
import SwiftUI

struct CafeReportView: View, KeyboardPresentationReadable {
  let store: StoreOf<CafeReport>

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        ScrollViewReader { proxy in
          ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
              photoMenuView
              cafeSearchButton
              mandatoryMenuView
              optionalMenuView
              reviewTextView
              reportButtonView
                .padding(.bottom, viewStore.textViewBottomPadding)
                .id(viewStore.textViewDidBeginEditingScrollId)
            }
            .padding(.horizontal, 20)
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
          .onReceive(keyboardEventPublisher) { isKeyboardShowing in
            viewStore.send(.updateTextViewBottomPadding(isTextViewEditing: isKeyboardShowing))

            if isKeyboardShowing {
              proxy.scrollTo(viewStore.textViewDidBeginEditingScrollId, anchor: .bottom)
            }
          }
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
          .onTapGesture {
            UIApplication.keyWindow?.endEditing(true)
          }
        }
      }
    )
  }
}

extension CafeReportView {
  private var photoMenuView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        ScrollView(.horizontal) {
          HStack {
            ForEach(viewStore.photoMenuItemViewState) { viewState in
              switch viewState.type {
              case .photoItem(let data):
                photoItemView(data: data)
              case .photoAddButton:
                photoAddButton
              }
            }
          }
        }
        .padding(.top, 39)
        .padding(.bottom, 40)
      }
    )
  }

  private func photoItemView(data: Data) -> some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .center) {
          if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
              .resizable()
              .frame(width: 138, height: 110)
              .cornerRadius(8)
          }
        }
      }
    )
  }

  private var photoAddButton: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .center) {
          PhotosPicker(
            selection: viewStore.binding(
              get: \.photosPickerItems,
              send: { items in
                  .set(\.$photosPickerItems, items)
              }
            ),
            maxSelectionCount: 8,
            photoLibrary: .shared(),
            label: {
              VStack(spacing: 4) {
                CofficeAsset.Asset.plusCircle24px.swiftUIImage
                HStack(alignment: .center, spacing: 2) {
                  Text("사진 추가")
                    .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
                    .applyCofficeFont(font: .body2Medium)
                  Text("*")
                    .foregroundColor(.red)
                    .applyCofficeFont(font: .body2Medium)
                }
                HStack(alignment: .center, spacing: 0) {
                  Text("\(viewStore.photosPickerItems.count)")
                    .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                    .applyCofficeFont(font: .body2Medium)
                  Text(" / 8")
                    .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
                    .applyCofficeFont(font: .body2Medium)
                }
              }
              .frame(width: 138, height: 110)
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
                  .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
              )
            }
          )
        }
      }
    )
  }

  private var cafeSearchButton: some View {
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

  private var mandatoryMenuView: some View {
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

          VStack(alignment: .leading, spacing: 0) {
            ForEach(viewStore.mandatoryMenuCellStates) { cellState in
              Text(cellState.title)
                .foregroundColor(CofficeAsset.Colors.grayScale8.swiftUIColor)
                .applyCofficeFont(font: .button)
                .padding(.bottom, 4)
              HStack {
                Text(cellState.description)
                  .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
                  .applyCofficeFont(font: .body2)

                Button {
                  // TODO: info button event 추가 필요
                } label: {
                  CofficeAsset.Asset.informationLine18px.swiftUIImage
                    .renderingMode(.template)
                    .foregroundColor(CofficeAsset.Colors.grayScale4.swiftUIColor)
                }

                Spacer()
              }
              .padding(.bottom, 20)

              HStack(spacing: 8) {
                ForEach(cellState.optionButtonStates) { buttonState in
                  Button {
                    viewStore.send(.mandatoryMenuTapped(
                      menu: cellState.menuType, buttonState: buttonState)
                    )
                    debugPrint("selected buttonState : \(buttonState)")
                  } label: {
                    Text(buttonState.title)
                      .applyCofficeFont(font: buttonState.titleFont)
                      .foregroundColor(buttonState.foregroundColor.swiftUIColor)
                      .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                      .cornerRadius(16)
                      .background(buttonState.backgroundColor.swiftUIColor.clipShape(Capsule()))
                      .cornerRadius(18)
                      .overlay {
                        RoundedRectangle(cornerRadius: 18)
                          .stroke(buttonState.borderColor.swiftUIColor, lineWidth: 1)
                          .padding(1)
                      }
                      .frame(height: 34)
                  }
                }
              }
              .padding(.bottom, 24)
            }
          }
        }
        .padding(.vertical, 16)
      }
    )
  }

  private var optionalMenuView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .leading, spacing: 0) {
          HStack(alignment: .center, spacing: 8) {
            Text("어떤 점이 더 좋았나요?")
              .applyCofficeFont(font: .header2)
              .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
              .frame(height: 24)

            Text("(선택)")
              .applyCofficeFont(font: .body1Medium)
              .foregroundColor(CofficeAsset.Colors.grayScale5.swiftUIColor)
              .frame(height: 20)

            Spacer()
          }
          .padding(.bottom, 32)

          VStack(alignment: .leading, spacing: 0) {
            ForEach(viewStore.optionalMenuCellStates) { cellState in
              HStack(spacing: 8) {
                Text(cellState.title)
                  .foregroundColor(CofficeAsset.Colors.grayScale8.swiftUIColor)
                  .applyCofficeFont(font: .button)
                  .padding(.trailing, 20)
                  .padding(.bottom, 4)

                ForEach(cellState.optionButtonStates) { buttonState in
                  Button {
                    viewStore.send(.optionalMenuTapped(
                      menu: cellState.menuType, buttonState: buttonState)
                    )
                    debugPrint("selected buttonState : \(buttonState)")
                  } label: {
                    Text(buttonState.title)
                      .applyCofficeFont(font: buttonState.titleFont)
                      .foregroundColor(buttonState.foregroundColor.swiftUIColor)
                      .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                      .cornerRadius(16)
                      .background(buttonState.backgroundColor.swiftUIColor.clipShape(Capsule()))
                      .cornerRadius(18)
                      .overlay {
                        RoundedRectangle(cornerRadius: 18)
                          .stroke(buttonState.borderColor.swiftUIColor, lineWidth: 1)
                          .padding(1)
                      }
                      .frame(height: 34)
                  }
                }
              }
              .padding(.bottom, 16)
            }
          }
        }
        .padding(.top, 16)
      }
    )
  }

  private var reviewTextView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        ZStack(alignment: .topLeading) {
          VStack(alignment: .leading, spacing: 0) {
            CafeReviewTextView(
              text: viewStore.binding(
                get: \.reviewText,
                send: { .set(\.$reviewText, $0) }
              )
            )
            .textFieldStyle(.plain)
            .frame(height: 206)
            .overlay(
              textDescriptionView,
              alignment: .bottomTrailing
            )
            .padding(13)
            .overlay {
              RoundedRectangle(cornerRadius: 8)
                .stroke(
                  CofficeAsset.Colors.grayScale3.swiftUIColor,
                  lineWidth: 1
                )
            }
          }
          .padding(.top, 16)

          if viewStore.shouldPresentTextViewPlaceholder {
            Text(viewStore.textViewPlaceholder)
              .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
              .applyCofficeFont(font: .paragraph)
              .padding(.top, 36)
              .padding(.leading, 20)
              .allowsHitTesting(false)
          }
        }
        .padding(.bottom, 38)
      }
    )
  }

  private var textDescriptionView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        HStack(alignment: .bottom, spacing: 0) {
          Text(viewStore.currentTextLengthDescription)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .applyCofficeFont(font: .body3Medium)
          Text(viewStore.maximumTextLengthDescription)
            .foregroundColor(CofficeAsset.Colors.grayScale5.swiftUIColor)
            .applyCofficeFont(font: .body3Medium)
        }
      }
    )
  }

  private var reportButtonView: some View {
    Button {
      // TODO: report button action 구현 필요
    } label: {
      Text("카페 등록하기")
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
    .padding(.top, 8)
    .padding(.bottom, 0)
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
