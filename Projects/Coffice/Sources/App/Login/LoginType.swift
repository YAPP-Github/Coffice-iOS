//
//  LoginType.swift
//  coffice
//
//  Created by 천수현 on 2023/06/17.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import SwiftUI

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
      return "카카오 로그인"
    case .apple:
      return "Apple 로그인"
    case .anonymous:
      return "없음"
    }
  }

  var image: Image {
    switch self {
    case .kakao:
      return CofficeAsset.Asset.kakaoLogoFill18px.swiftUIImage
    case .apple:
      return CofficeAsset.Asset.appleLogo18px.swiftUIImage
    case .anonymous:
      return Image(systemName: "person")
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
