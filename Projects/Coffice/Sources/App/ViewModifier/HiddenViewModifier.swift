//
//  HiddenWithOpacityViewModifier.swift
//  coffice
//
//  Created by Min Min on 2023/07/23.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct HiddenWithOpacityViewModifier: ViewModifier {
  private let isHidden: Bool

  init(isHidden: Bool) {
    self.isHidden = isHidden
  }

  func body(content: Content) -> some View {
    content
      .opacity(isHidden ? 0 : 1)
  }
}
