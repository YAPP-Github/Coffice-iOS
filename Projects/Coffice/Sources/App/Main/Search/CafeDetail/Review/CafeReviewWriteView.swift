//
//  CafeReviewWriteView.swift
//  coffice
//
//  Created by Min Min on 2023/06/29.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct CafeReviewWriteView: View {
  private let store: StoreOf<CafeReviewWrite>

  init(store: StoreOf<CafeReviewWrite>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          HStack {
            Text("리뷰 쓰기")
              .applyCofficeFont(font: .header1)
              .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
              .padding(.vertical, 4)
            Spacer()
            Button {
              viewStore.send(.presentDeleteConfirmBottomSheet)
            } label: {
              CofficeAsset.Asset.close40px.swiftUIImage
            }
          }
          .padding(.top, 24)
          .padding(.horizontal, 20)
          .padding(.bottom, 16)

          HStack(spacing: 16) {
            ZStack {
              CofficeAsset.Colors.grayScale2.swiftUIColor

              Group {
                if let imageUrl = viewStore.imageUrl {
                  LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.06), .black.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                  )
                  .background(alignment: .center) {
                    KFImage.url(imageUrl)
                      .resizable()
                      .scaledToFill()
                  }
                } else {
                  placeholderImage
                }
              }
            }
            .frame(width: 48, height: 48)
            .cornerRadius(4, corners: .allCorners)

            VStack(spacing: 0) {
              Text(viewStore.cafeName)
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .subtitleSemiBold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20, alignment: .center)

              Spacer()

              Text(viewStore.cafeAddress)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                .applyCofficeFont(font: .body1Medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20, alignment: .center)
            }
            .frame(height: 48)
          }
          .padding(.top, 4)
          .padding(.bottom, 16)
          .padding(.horizontal, 20)

          CofficeAsset.Colors.grayScale3.swiftUIColor
            .frame(height: 1)
            .padding(.horizontal, 20)

          reviewFormScrollView

          VStack(alignment: .center) {
            Button {
              viewStore.send(.saveButtonTapped)
            } label: {
              Text(viewStore.saveButtonTitle)
                .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
                .applyCofficeFont(font: .button)
                .frame(maxWidth: .infinity)
            }
            .disabled(viewStore.isSaveButtonEnabled.isFalse)
          }
          .frame(height: 44)
          .background(viewStore.saveButtonBackgroundColorAsset.swiftUIColor)
          .cornerRadius(4, corners: .allCorners)
          .padding(.horizontal, 20)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
          viewStore.send(.onAppear)
        }
        .onTapGesture {
          UIApplication.keyWindow?.endEditing(true)
        }
        .popup(
          item: viewStore.binding(
            get: \.dismissConfirmBottomSheetState,
            send: { .set(\.$dismissConfirmBottomSheetState, $0) }
          ),
          itemView: { sheetState in
            BottomSheetView(
              store: store.scope(
                state: { _ in sheetState },
                action: CafeReviewWrite.Action.dismissConfirmBottomSheet
              ),
              bottomSheetContent: viewStore.deleteConfirmBottomSheetType.content
            )
          },
          customize: {
            BottomSheetContent.customize($0)
              .dismissCallback {
                viewStore.send(.dismissConfirmBottomSheetDismissed)
              }
          }
        )
      }
    )
  }
}

extension CafeReviewWriteView: KeyboardPresentationReadable {
  private var reviewFormScrollView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        ScrollViewReader { proxy in
          ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
              reviewOptionMenuView
                .id(viewStore.textViewDidEndEditingScrollId)
                .padding(.horizontal, 20)
              reviewTextView
                .padding(.bottom, viewStore.textViewBottomPadding)
                .id(viewStore.textViewDidBeginEditingScrollId)
                .padding(.horizontal, 20)
            }
          }
          .onReceive(keyboardEventPublisher) { isKeyboardShowing in
            viewStore.send(.updateTextViewBottomPadding(isTextViewEditing: isKeyboardShowing))

            if isKeyboardShowing {
              proxy.scrollTo(viewStore.textViewDidBeginEditingScrollId, anchor: .bottom)
            } else {
              proxy.scrollTo(viewStore.textViewDidEndEditingScrollId, anchor: .bottom)
            }
          }
        }
      }
    )
  }

  private var reviewOptionMenuView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .leading, spacing: 0) {
          ForEach(viewStore.optionButtonStates) { buttonState in
            CafeReviewOptionButtonsView(
              store: store.scope(
                state: { _ in buttonState },
                action: CafeReviewWrite.Action.optionButtonsAction
              )
            )
          }
        }
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
            Text(
            """
            혼자서 오기 좋았나요?
            테이블, 의자는 편했나요?
            카페에서 작업하며 느꼈던 점들을 공유해주세요!
            """
            )
            .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
            .applyCofficeFont(font: .paragraph)
            .padding(.top, 36)
            .padding(.leading, 20)
            .allowsHitTesting(false)
          }
        }
        .padding(.bottom, 58)
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

  private var placeholderImage: some View {
    CofficeAsset.Asset.icPlaceholder.swiftUIImage
      .resizable()
      .frame(width: 20, height: 20)
  }
}

struct CafeReviewWriteView_Previews: PreviewProvider {
  static var previews: some View {
    CafeReviewWriteView(
      store: .init(
        initialState: .mock,
        reducer: {
          CafeReviewWrite()
        }
      )
    )
  }
}
