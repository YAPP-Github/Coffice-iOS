//
//  UITextView+Extensions.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import UIKit

extension UITextView {
  func applyCoffice(font: CofficeFont) {
    self.font = UIFont(name: font.name, size: font.size)
  }
}
