//
//  CapacityLevel.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum CapacityLevel: Hashable {
  case unknown
  case low
  case medium
  case high

  static func level(of capacity: String) -> CapacityLevel? {
    switch capacity {
    case "UNKNOWN": return .unknown
    case "LOW": return .low
    case "MEDIUM": return .medium
    case "HIGH": return .high
    default: return nil
    }
  }

  var dtoName: String {
    switch self {
    case .unknown: return "UNKNOWN"
    case .low: return "LOW"
    case .medium: return "MEDIUM"
    case .high: return "HIGH"
    }
  }
}
