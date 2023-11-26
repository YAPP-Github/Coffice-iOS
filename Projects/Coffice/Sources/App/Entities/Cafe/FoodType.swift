//
//  FoodType.swift
//  coffice
//
//  Created by 천수현 on 2023/07/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum FoodType: Hashable, CaseIterable {
  case dessert
  case glutenFree
  case mealWorthy
  case unknown

  static func type(of foodType: String) -> FoodType? {
    switch foodType {
    case "DESSERT": return .dessert
    case "GLUTEN_FREE": return .glutenFree
    case "MEAL_WORTHY": return .mealWorthy
    default: return nil
    }
  }

  var dtoName: String {
    switch self {
    case .dessert: return "DESSERT"
    case .glutenFree: return "GLUTEN_FREE"
    case .mealWorthy: return "MEAL_WORTHY"
    case .unknown: return "UNKNOWN"
    }
  }

  var text: String {
    switch self {
    case .dessert: return "디저트"
    case .glutenFree: return "글루텐 프리"
    case .mealWorthy: return "식사 가능"
    case .unknown: return "-"
    }
  }

  var reportOptionText: String {
    text
  }
}
