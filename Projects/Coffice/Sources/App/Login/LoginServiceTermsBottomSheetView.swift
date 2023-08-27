//
//  LoginServiceTermsBottomSheetView.swift
//  coffice
//
//  Created by Min Min on 2023/07/20.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct LoginServiceTermsBottomSheetView: View {
  private let store: StoreOf<LoginServiceTermsBottomSheet>

  init(store: StoreOf<LoginServiceTermsBottomSheet>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Text("이용 약관 동의")
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .applyCofficeFont(font: .header1)
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(height: 32)
          .padding(.top, 28)
          .padding(.bottom, 20)

        Button {
          viewStore.send(.wholeTermsAgreementButtonTapped)
        } label: {
          HStack(spacing: 16) {
            viewStore.wholeTermsAgreementCheckboxImage.swiftUIImage
              .renderingMode(.template)
              .foregroundColor(viewStore.wholeTermsAgreementCheckboxColor.swiftUIColor)
            Text("약관 전체 동의")
              .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
              .applyCofficeFont(font: .subtitle1Medium)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .frame(height: 32)
        .padding(.vertical, 20)

        CofficeAsset.Colors.grayScale3.swiftUIColor
          .frame(height: 1)
          .padding(.bottom, 20)

        VStack(spacing: 0) {
          ForEach(viewStore.termsOptionButtonViewStates) { viewState in
            HStack(spacing: 16) {
              Button {
                viewStore.send(.termsOptionButtonTapped(viewState: viewState))
              } label: {
                HStack {
                  viewState.checkboxImage.swiftUIImage
                    .renderingMode(.template)
                    .foregroundColor(viewState.checkboxImageColor.swiftUIColor)
                  Text(viewState.title)
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                    .applyCofficeFont(font: .subtitle1Medium)
                  Text("(필수)")
                    .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
                    .applyCofficeFont(font: .subtitle1Medium)
                  Spacer()
                }
                .frame(height: 32)
              }

              Button {
                viewStore.send(.termsWebMenuButtonTapped(viewState: viewState))
              } label: {
                CofficeAsset.Asset.arrowDropRightLine24px.swiftUIImage
              }
            }
            .padding(.bottom, 20)
          }
        }

        Button {
          viewStore.send(.delegate(.confirmButtonTapped))
        } label: {
          Text("확인")
            .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
            .applyCofficeFont(font: .button)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 44)
            .background(
              viewStore.confirmButtonBackgroundColor.swiftUIColor
                .frame(height: 44)
                .cornerRadius(4, corners: .allCorners)
            )
        }
        .padding(.vertical, 20)
        .disabled(viewStore.isWholeTermsAgreed.isFalse)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, UIApplication.keyWindow?.safeAreaInsets.bottom ?? 0)
      .background(
        CofficeAsset.Colors.grayScale1.swiftUIColor
          .cornerRadius(18, corners: [.topLeft, .topRight])
      )
      .onAppear {
        viewStore.send(.onAppear)
      }
      .sheet(
        item: viewStore.$webViewState,
        content: { viewState in
          VStack(spacing: 0) {
            CommonWebView(
              store: store.scope(
                state: { _ in viewState },
                action: LoginServiceTermsBottomSheet.Action.commonWebReducerAction
              )
            )
          }
          .customNavigationBar(
            centerView: {
              Text(viewStore.webViewTitle)
            },
            leftView: {
              EmptyView()
            },
            rightView: {
              Button {
                viewStore.send(.dismissWebView)
              } label: {
                CofficeAsset.Asset.close40px.swiftUIImage
              }
            }
          )
        }
      )
    }
  }
}

struct LoginServiceTermsSheetView_Previews: PreviewProvider {
  static var previews: some View {
    LoginServiceTermsBottomSheetView(
      store: .init(
        initialState: .initialState,
        reducer: {
          LoginServiceTermsBottomSheet()
        }
      )
    )
  }
}
