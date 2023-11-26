//
//  ElectricOutletLevel.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum ElectricOutletLevel: Hashable, CaseIterable {
  case unknown
  case few
  case several
  case many

  static func level(of capacity: String) -> ElectricOutletLevel {
    switch capacity {
    case "UNKNOWN": return .unknown
    case "FEW": return .few
    case "SEVERAL": return .several
    case "MANY": return .many
    default: return .unknown
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

  var iconName: String {
    switch self {
    case .unknown:
      return CofficeAsset.Asset.outletFew44px.name // TODO: Unknown 처리
    case .few:
      return CofficeAsset.Asset.outletFew44px.name
    case .several:
      return CofficeAsset.Asset.outletSeveral44px.name
    case .many:
      return CofficeAsset.Asset.outletMany44px.name
    }
  }

  var text: String {
    switch self {
    case .many: return "🔌 콘센트 넉넉"
    case .several: return "🔌 콘센트 보통"
    case .few: return "🔌 콘센트 부족"
    default: return "🔌 콘센트 정보 없음"
    }
  }

  var informationText: String {
    switch self {
    case .many: return "넉넉"
    case .several: return "보통"
    case .few: return "부족"
    default: return "-"
    }
  }

  var reportOptionText: String {
    informationText
  }
}
