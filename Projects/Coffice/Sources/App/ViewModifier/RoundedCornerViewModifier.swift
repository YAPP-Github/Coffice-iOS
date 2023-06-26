//
//  RoundedCornerViewModifier.swift
//  coffice
//
//  Created by sehooon on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct RoundedCornerViewModifier: ViewModifier {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  private var roundedCorner: RoundedCorner

  init(radius: CGFloat, corners: UIRectCorner) {
    self.radius = radius
    self.corners = corners
    self.roundedCorner = RoundedCorner(radius: radius, corners: corners)
  }

  func body(content: Content) -> some View {
    content
      .clipShape(RoundedCorner(radius: radius, corners: corners))
  }

  struct RoundedCorner: Shape {
      var radius: CGFloat = .infinity
      var corners: UIRectCorner = .allCorners

      func path(in rect: CGRect) -> Path {
          let path = UIBezierPath(
            roundedRect: rect, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
          )
          return Path(path.cgPath)
      }
  }
}
