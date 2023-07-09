//
//  CommonBottomSheetView.swift
//  coffice
//
//  Created by 천수현 on 2023/07/08.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CommonBottomSheetView: View {
  private let store: StoreOf<CommonBottomSheet>

  init(store: StoreOf<CommonBottomSheet>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack(alignment: .bottom) {
        backgroundView
        if viewStore.isBottomSheetPresented {
          VStack(spacing: 12) {
            informationView
            footerView
          }
          .scaledToFit()
          .padding(.bottom, UIApplication.keyWindow?.safeAreaInsets.bottom)
          .padding(.top, 20)
          .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
          .cornerRadius(12, corners: [.topLeft, .topRight])
        }
      }
      .ignoresSafeArea()
      .animation(
        .easeIn(duration: viewStore.dismissAnimationDuration),
        value: viewStore.isBottomSheetPresented
      )
    }
  }
}

extension CommonBottomSheetView {
  private var backgroundView: some View {
    WithViewStore(store) { viewStore in
      CofficeAsset.Colors.grayScale10.swiftUIColor
        .opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture {
          viewStore.send(.backgroundViewTapped)
        }
        .onAppear {
          viewStore.send(.presentBottomSheet)
        }
    }
  }

  private var informationView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        CofficeAsset.Asset.errorWarningFill40px.swiftUIImage
          .renderingMode(.template)
          .foregroundColor(CofficeAsset.Colors.grayScale5.swiftUIColor)
          .frame(width: 40, height: 40)

        Text(viewStore.title)
          .applyCofficeFont(font: .header2)
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .padding(.top, 20)

        Text(viewStore.description)
          .multilineTextAlignment(.center)
          .applyCofficeFont(font: .subtitle1Medium)
          .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
          .padding(.top, 12)
      }
      .padding(.vertical, 20)
    }
  }

  private var footerView: some View {
    WithViewStore(store) { viewStore in
      HStack(alignment: .center, spacing: 12) {
        cancelButton
        confirmButton
      }
      .padding(.horizontal, 20)
    }
  }

  private var cancelButton: some View {
    WithViewStore(store) { viewStore in
      Button {
        viewStore.send(.cancelButtonTapped)
      } label: {
        Text(viewStore.cancelButtonTitle)
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .applyCofficeFont(font: .button)
          .frame(maxWidth: .infinity, alignment: .center)
          .frame(height: 44)
          .overlay {
            RoundedRectangle(cornerRadius: 4)
              .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
          }
      }
    }
  }

  private var confirmButton: some View {
    WithViewStore(store) { viewStore in
      Button {
        viewStore.send(.confirmButtonTapped)
      } label: {
        Text(viewStore.confirmButtonTitle)
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
  }
}

struct CommonBottomSheetView_Previews: PreviewProvider {
  static var previews: some View {
    CommonBottomSheetView(
      store: .init(
        initialState: .mock,
        reducer: CommonBottomSheet()
      )
    )
  }
}
