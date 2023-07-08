//
//  Collection+Extensions.swift
//  coffice
//
//  Created by Min Min on 2023/07/06.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }

  var isNotEmpty: Bool { !isEmpty }
}
