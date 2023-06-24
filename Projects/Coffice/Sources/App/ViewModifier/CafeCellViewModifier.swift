//
//  CafeCellViewModifier.swift
//  coffice
//
//  Created by sehooon on 2023/06/23.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import SwiftUI

struct CafeCellViewModifier: ViewModifier {
  let fontColor: Color

  init(fontColor: Color) {
    self.fontColor = fontColor
  }

  func body(content: Content) -> some View {
    content
      .foregroundColor(.red)
      .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
      .overlay {
        RoundedRectangle(cornerRadius: 4)
          .stroke(Color.red, lineWidth: 1)
      }
  }
}
