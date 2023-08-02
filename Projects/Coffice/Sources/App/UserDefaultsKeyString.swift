//
//  UserDefaultsKeyString.swift
//  coffice
//
//  Created by sehooon on 2023/08/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum UserDefaultsKeyString {
  case onBoardingWithCafeMapView

  var forKey: String {
    switch self {
    case .onBoardingWithCafeMapView:
      return "onBoardingWithCafeMapView"
    }
  }
}
