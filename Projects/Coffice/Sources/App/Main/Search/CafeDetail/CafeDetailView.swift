//
//  CafeSearchDetailView.swift
//  coffice
//
//  Created by Min Min on 2023/06/24.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeDetailView: View {
  private let store: StoreOf<CafeDetail>

  init(store: StoreOf<CafeDetail>) {
    self.store = store
  }

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        ScrollView(.vertical) {
          VStack(spacing: 0) {
            CafeDetailHeaderView(store: store)
            CafeDetailSubInfoView(store: store)
            CafeDetailMenuView(store: store)
          }
        }
      }
      .navigationBarHidden(true)
      .ignoresSafeArea(.all, edges: .top)
      .overlay(
        alignment: .top,
        content: {
          HStack {
            Button {
              viewStore.send(.popView)
            } label: {
              CofficeAsset.Asset.arrowLeftSLine40px.swiftUIImage
                .renderingMode(.template)
                .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
            }

            Spacer()

            Button {
              // TODO: 공유하기 기능 추가 필요
            } label: {
              CofficeAsset.Asset.shareBoxFill40px.swiftUIImage
                .renderingMode(.template)
                .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
            }
          }
          .padding(.top, 4)
          .padding(.horizontal, 8)
        }
      )
      .onAppear {
        viewStore.send(.onAppear)
      }
      .sheet(
        item: viewStore.binding(\.$cafeReviewWriteState),
        content: { viewState in
          CafeReviewWriteView(
            store: store.scope(
              state: { _ in viewState },
              action: CafeDetail.Action.cafeReviewWrite(action:)
            )
          )
        }
      )
      .popup(
        isPresented: viewStore.binding(\.$isReviewModifySheetPresented),
        view: {
          VStack(spacing: 12) {
            Button {
              viewStore.send(.reviewEditSheetButtonTapped)
            } label: {
              Text("수정하기")
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .button)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 52)
                .padding(.top, 20)
            }

            Button {
              viewStore.send(.reviewDeleteSheetButtonTapped)
            } label: {
              Text("삭제하기")
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .button)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 52)
            }

            Spacer()
          }
          .padding(.horizontal, 20)
          .frame(height: 196)
          .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
          .cornerRadius(12, corners: [.topLeft, .topRight])
        },
        customize: { popup in
          popup
            .type(.toast)
            .position(.bottom)
            .isOpaque(true)
            .closeOnTapOutside(true)
            .backgroundColor(CofficeAsset.Colors.grayScale10.swiftUIColor.opacity(0.4))
            .dismissCallback {
              viewStore.send(.reviewModifySheetDismissed)
            }
        }
      )
      .popup(
        isPresented: viewStore.binding(\.$isReviewReportSheetPresented),
        view: {
          VStack(spacing: 12) {
            Button {
              viewStore.send(.reviewReportSheetButtonTapped)
            } label: {
              Text("신고하기")
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .button)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 52)
                .padding(.top, 20)
            }

            Spacer()
          }
          .padding(.horizontal, 20)
          .frame(height: 132)
          .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
          .cornerRadius(12, corners: [.topLeft, .topRight])
        },
        customize: { popup in
          popup
            .type(.toast)
            .position(.bottom)
            .isOpaque(true)
            .closeOnTapOutside(true)
            .backgroundColor(CofficeAsset.Colors.grayScale10.swiftUIColor.opacity(0.4))
        }
      )
      .popup(
        item: viewStore.binding(\.$deleteConfirmBottomSheetState),
        itemView: { sheetState in
          BottomSheetView(
            store: store.scope(
              state: { _ in sheetState },
              action: CafeDetail.Action.bottomSheet
            ),
            bottomSheetContent: viewStore.bottomSheetType.content
          )
        },
        customize: { BottomSheetContent.customize($0) }
      )
      .popup(
        item: viewStore.binding(\.$toastViewMessage),
        itemView: { message in
          ToastView(
            title: message,
            image: CofficeAsset.Asset.checkboxCircleFill18px,
            config: ToastConfiguration.default
          )
        },
        customize: {
          $0
            .type(.floater(verticalPadding: 16, horizontalPadding: 0, useSafeAreaInset: false))
            .autohideIn(2)
        }
      )
    }
  }
}

struct CafeSearchDetailView_Previews: PreviewProvider {
  static var previews: some View {
    CafeDetailView(
      store: .init(
        initialState: .init(cafeId: 1),
        reducer: CafeDetail()
      )
    )
  }
}
