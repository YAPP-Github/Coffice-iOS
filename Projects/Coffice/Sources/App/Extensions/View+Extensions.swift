//
//  View+Extensions.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import SwiftUI

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    modifier(RoundedCornerViewModifier(radius: radius, corners: corners))
  }

  func cafeCellViewModifier(fontColor: Color) -> some View {
    modifier(CafeCellViewModifier(fontColor: fontColor))
  }

  func customSheet<ViewContent>(
    viewContent: @escaping () -> ViewContent
  ) -> some View where ViewContent: View {
    modifier(CustomBottomSheetViewModifier(viewContent: viewContent))
  }

  func customNavigationBar<C, L, R>(
    centerView: @escaping (() -> C),
    leftView: @escaping (() -> L),
    rightView: @escaping (() -> R)
  ) -> some View where C: View, L: View, R: View {
    modifier(
      CustomNavigationBarModifier(centerView: centerView, leftView: leftView, rightView: rightView)
    )
  }

  func customNavigationBar<C, L>(
    centerView: @escaping (() -> C),
    leftView: @escaping (() -> L)
  ) -> some View where C: View, L: View {
    modifier(
      CustomNavigationBarModifier(
        centerView: centerView,
        leftView: leftView,
        rightView: {
          EmptyView()
        }
      )
    )
  }

  func customNavigationBar<V>(
    centerView: @escaping (() -> V)
  ) -> some View where V: View {
    modifier(
      CustomNavigationBarModifier(
        centerView: centerView,
        leftView: {
          EmptyView()
        }, rightView: {
          EmptyView()
        }
      )
    )
  }
}
