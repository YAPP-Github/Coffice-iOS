//
//  CafeTagTextModifier.swift
//  coffice
//
//  Created by sehooon on 2023/07/18.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import SwiftUI

struct CafeTagTextModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
      .applyCofficeFont(font: .body2Medium)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(
        RoundedRectangle(cornerRadius: 4)
          .stroke(
            CofficeAsset.Colors.grayScale3.swiftUIColor,
            lineWidth: 1
          )
      )
  }
}




