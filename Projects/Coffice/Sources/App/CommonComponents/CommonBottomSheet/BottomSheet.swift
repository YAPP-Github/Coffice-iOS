//
//  BottomSheet.swift
//  coffice
//
//  Created by 천수현 on 2023/07/11.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation
import PopupView
import SwiftUI

struct BottomSheetContent: Equatable {
  static func customize<PopupContent: View>(
    _ view: Popup<PopupContent>.PopupParameters
  ) -> Popup<PopupContent>.PopupParameters {
    view
      .type(.toast)
      .position(.bottom)
      .isOpaque(true)
      .closeOnTapOutside(true)
      .closeOnTap(false)
      .backgroundColor(CofficeAsset.Colors.grayScale10.swiftUIColor.opacity(0.4))
      .animation(.easeOut(duration: 0.2))
  }
  static let mock = BottomSheetContent(
    title: "제목",
    description: "내용",
    confirmButtonTitle: "확인",
    cancelButtonTitle: "취소"
  )

  static func == (lhs: BottomSheetContent, rhs: BottomSheetContent) -> Bool {
    lhs.id == rhs.id
  }

  private let id = UUID()
  let title: String
  let description: String
  let confirmButtonTitle: String
  let cancelButtonTitle: String
}

struct BottomSheetView: View {
  let store: StoreOf<BottomSheetReducer>
  let bottomSheetContent: BottomSheetContent

  var body: some View {
    VStack(spacing: 12) {
      informationView
      footerView
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 20 + (UIApplication.keyWindow?.safeAreaInsets.bottom ?? 0))
    .padding(.top, 20)
    .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
    .cornerRadius(12, corners: [.topLeft, .topRight])
    .transition(.move(edge: .bottom))
  }
}

extension BottomSheetView {
  private var informationView: some View {
    VStack(spacing: 0) {
      CofficeAsset.Asset.errorWarningFill40px.swiftUIImage
        .renderingMode(.template)
        .foregroundColor(CofficeAsset.Colors.grayScale5.swiftUIColor)
        .frame(width: 40, height: 40)

      Text(bottomSheetContent.title)
        .applyCofficeFont(font: .header2)
        .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
        .padding(.top, 20)

      Text(bottomSheetContent.description)
        .multilineTextAlignment(.center)
        .applyCofficeFont(font: .subtitle1Medium)
        .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
        .padding(.top, 12)
    }
    .padding(.vertical, 20)
  }

  private var footerView: some View {
    HStack(alignment: .center, spacing: 12) {
      cancelButton
      confirmButton
    }
    .padding(.horizontal, 20)
  }

  private var cancelButton: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        Button {
          viewStore.send(.cancelButtonTapped)
        } label: {
          Text(bottomSheetContent.cancelButtonTitle)
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
    )
  }

  private var confirmButton: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        Button {
          viewStore.send(.confirmButtonTapped)
        } label: {
          Text(bottomSheetContent.confirmButtonTitle)
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
    )
  }
}

struct BottomSheetView_Previews: PreviewProvider {
  static var previews: some View {
    BottomSheetView(
      store: .init(
        initialState: .initialState,
        reducer: {
          BottomSheetReducer()
        }
      ),
      bottomSheetContent: .mock
    )
  }
}
