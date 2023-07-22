//
//  ElectricOutletLevel.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum ElectricOutletLevel {
  case unknown
  case few
  case several
  case many

  static func level(of capacity: String) -> ElectricOutletLevel? {
    switch capacity {
    case "UNKNOWN": return .unknown
    case "FEW": return .few
    case "SEVERAL": return .several
    case "MANY": return .many
    default: return nil
    }
  }

  var dtoName: String {
    switch self {
    case .unknown: return "UNKNOWN"
    case .few: return "FEW"
    case .several: return "SEVERAL"
    case .many: return "MANY"
    }
  }
}
