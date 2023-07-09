//
//  TabbarPreferenceKey.swift
//  coffice
//
//  Created by sehooon on 2023/06/29.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import SwiftUI

struct TabBarSizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .init(width: UIScreen.main.bounds.width, height: 65)
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}
