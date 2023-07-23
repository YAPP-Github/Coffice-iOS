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

  static func level(of capacity: String) -> CapacityLevel {
    switch capacity {
    case "UNKNOWN": return .unknown
    case "LOW": return .low
    case "MEDIUM": return .medium
    case "HIGH": return .high
    default: return .unknown
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

  var text: String {
    switch self {
    case .high: return "🗄️ 대형카페"
    case .medium: return "🗄️ 중형카페"
    case .low: return "🗄️ 소형카페"
    default: return ""
    }
  }

  var informationText: String {
    switch self {
    case .high: return "대형"
    case .medium: return "중형"
    case .low: return "소형"
    default: return "정보 없음"
    }
  }

  var iconName: String {
    switch self {
    case .unknown:
      return CofficeAsset.Asset.cafeSizeSmall44px.name // TODO: Unknown 처리
    case .low:
      return CofficeAsset.Asset.cafeSizeSmall44px.name
    case .medium:
      return CofficeAsset.Asset.cafeSizeMedium44px.name
    case .high:
      return CofficeAsset.Asset.cafeSizeLarge44px.name
    }
  }
}
