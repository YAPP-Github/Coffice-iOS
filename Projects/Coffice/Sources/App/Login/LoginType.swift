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
}
