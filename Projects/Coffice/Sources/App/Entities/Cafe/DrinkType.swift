//
//  DrinkType.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum DrinkType: Hashable {
  case decaffeinated
  case soyMilk

  static func type(of drinkType: String) -> DrinkType? {
    switch drinkType {
    case "DECAFFEINATED": return .decaffeinated
    case "SOY_MILK": return .soyMilk
    default: return nil
    }
  }

  var dtoName: String {
    switch self {
    case .decaffeinated: return "DECAFFEINATED"
    case .soyMilk: return "SOY_MILK"
    }
  }
}
