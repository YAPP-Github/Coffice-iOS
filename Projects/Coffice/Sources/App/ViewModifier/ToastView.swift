//
//  ToastView.swift
//  coffice
//
//  Created by 천수현 on 2023/06/30.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct Toast: ViewModifier {
  static let short: TimeInterval = 2
  static let long: TimeInterval = 3.5

  let message: String
  @Binding var isPresented: Bool
  let config = Config.default
  let image: Image

  func body(content: Content) -> some View {
    ZStack {
      content
      toastView
    }
  }

  private var toastView: some View {
    VStack {
      Spacer()
      if isPresented {
        HStack {
          image
          Text(message)
            .multilineTextAlignment(.center)
            .foregroundColor(config.textColor)
            .font(config.font)
            .padding(8)
        }
        .background(config.backgroundColor)
        .cornerRadius(8)
        .onTapGesture {
          isPresented = false
        }
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
            isPresented = false
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 18)
    .animation(config.animation, value: isPresented)
    .transition(config.transition)
  }

  struct Config {
    static let `default` = Config()
    let textColor: Color
    let font: Font
    let backgroundColor: Color
    let duration: TimeInterval
    let transition: AnyTransition
    let animation: Animation

    init(
      textColor: Color = .white,
      font: Font = .system(size: 14),
      backgroundColor: Color = .black.opacity(0.588),
      duration: TimeInterval = Toast.short,
      transition: AnyTransition = .opacity,
      animation: Animation = .linear(duration: 0.3)
    ) {
      self.textColor = textColor
      self.font = font
      self.backgroundColor = backgroundColor
      self.duration = duration
      self.transition = transition
      self.animation = animation
    }
  }
}
