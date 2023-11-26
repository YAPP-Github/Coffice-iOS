//
//  CafeGroupSeatLevel.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum CafeGroupSeatLevel: Hashable, CaseIterable {
  case isTrue
  case isFalse
  case unknown

  var iconName: String {
    switch self {
    case .isTrue:
      return CofficeAsset.Asset.groupseatTrue44px.name
    case .isFalse:
      return CofficeAsset.Asset.groupseatFalse44px.name
    case .unknown:
      return CofficeAsset.Asset.groupseatTrue44px.name // TODO: Unknown 추가 필요
    }
  }

  var text: String {
    return self == .isTrue ? "🪑 단체석" : ""
  }

  var informationText: String {
    switch self {
    case .isTrue:
      return "있음"
    case .isFalse:
      return "없음"
    case .unknown:
      return "-"
    }
  }

  var reportOptionText: String {
    switch self {
    case .isTrue:
      return "단체석 있음"
    case .isFalse:
      return "단체석 없음"
    case .unknown:
      return "-"
    }
  }

  static func level(of level: Bool) -> CafeGroupSeatLevel {
    switch level {
    case true:
      return .isTrue
    case false:
      return .isFalse
    }
  }
}
