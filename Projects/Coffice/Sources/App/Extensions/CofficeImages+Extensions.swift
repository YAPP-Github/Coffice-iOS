//
//  CofficeImages+Extensions.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

extension CofficeImages: Equatable {
  public static func == (lhs: CofficeImages, rhs: CofficeImages) -> Bool {
    lhs.name == rhs.name
  }
}
