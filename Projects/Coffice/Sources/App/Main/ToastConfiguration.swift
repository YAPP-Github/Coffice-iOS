//
//  ToastCore.swift
//  coffice
//
//  Created by 천수현 on 2023/07/01.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct ToastConfiguration: Equatable {
  static let `default` = ToastConfiguration()
  let textColor: Color
  let font: CofficeFont
  let backgroundColor: Color
  let duration: TimeInterval

  init(
    textColor: Color = CofficeAsset.Colors.grayScale1.swiftUIColor,
    font: CofficeFont = .body1Medium,
    backgroundColor: Color = CofficeAsset.Colors.grayScale8.swiftUIColor,
    duration: TimeInterval = 2
  ) {
    self.textColor = textColor
    self.font = font
    self.backgroundColor = backgroundColor
    self.duration = duration
  }
}
