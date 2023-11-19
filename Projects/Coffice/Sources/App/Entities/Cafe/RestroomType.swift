//
//  RestroomType.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum RestroomType: Hashable {
  case indoors
  case genderSeperated
  case unknown

  static func type(of restroomType: String) -> RestroomType? {
    switch restroomType {
    case "INDOORS": return .indoors
    case "GENDER_SEPARATED": return .genderSeperated
    default: return nil
    }
  }

  var text: String {
    switch self {
    case .indoors:
      return "실내"
    case .genderSeperated:
      return "남녀 개별"
    case .unknown:
      return "-"
    }
  }

  var dtoName: String {
    switch self {
    case .indoors: return "INDOORS"
    case .genderSeperated: return "GENDER_SEPARATED"
    case .unknown: return "UNKNOWN"
    }
  }
}
