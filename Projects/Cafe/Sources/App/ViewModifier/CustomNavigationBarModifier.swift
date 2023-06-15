//
//  CustomNavigationBarModifier.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import SwiftUI

/// Custom Navigation Bar
struct CustomNavigationBarModifier<C, L, R>: ViewModifier where C: View, L: View, R: View {
  let centerView: (() -> C)?
  let leftView: (() -> L)?
  let rightView: (() -> R)?
  var topSafeAreaInset: CGFloat {
    UIApplication.keyWindow?.safeAreaInsets.top ?? 0.0
  }

  init(centerView: (() -> C)? = nil, leftView: (() -> L)? = nil, rightView: (() -> R)? = nil) {
    self.centerView = centerView
    self.leftView = leftView
    self.rightView = rightView
  }

  func body(content: Content) -> some View {
    VStack {
      ZStack {
        HStack {
          leftView?()

          Spacer()

          rightView?()
        }
        .frame(height: 44.0)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16.0)

        HStack {
          Spacer()

          centerView?()

          Spacer()
        }
      }
      .background(Color.white.ignoresSafeArea())

      content

      Spacer()
    }
    .navigationBarHidden(true)
  }
}
