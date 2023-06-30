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
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}
