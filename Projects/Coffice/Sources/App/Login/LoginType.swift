//
//  LoginType.swift
//  coffice
//
//  Created by 천수현 on 2023/06/17.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum LoginType {
  case kakao
  case apple
  case anonymous

  var name: String {
    switch self {
    case .kakao:
      return "KAKAO"
    case .apple:
      return "APPLE"
    case .anonymous:
      return "ANONYMOUS"
    }
  }

  var displayName: String {
    switch self {
    case .kakao:
      return "카카오"
    case .apple:
      return "애플"
    case .anonymous:
      return "없음"
    }
  }

  static func type(of typeName: String) -> LoginType {
    switch typeName {
    case "KAKAO":
      return .kakao
    case "APPLE":
      return .apple
    default:
      return .anonymous
    }
  }
}
