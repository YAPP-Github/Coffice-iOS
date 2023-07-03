//
//  CafeFilters.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

struct CafeSearchFilters {
  let capacityLevels: [CapacityLevel]?
  let drinkTypes: [DrinkType]?
  let foodTypes: [FoodType]?
  let restroomTypes: [RestroomType]?
}

enum CapacityLevel {
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

enum DrinkType {
  case decaffeinated
  case soyMilk

  static func type(of drinkType: String) -> DrinkType? {
    switch drinkType {
    case "DECAFFEINATED": return .decaffeinated
    case "SOY_MILK": return .soyMilk
    default: return nil
    }
  }

  var dtoName: String {
    switch self {
    case .decaffeinated: return "DECAFFEINATED"
    case .soyMilk: return "SOY_MILK"
    }
  }
}

enum FoodType {
  case glutenFree
  case mealWorthy

  static func type(of foodType: String) -> FoodType? {
    switch foodType {
    case "GLUTEN_FREE": return .glutenFree
    case "MEAL_WORTHY": return .mealWorthy
    default: return nil
    }
  }

  var dtoName: String {
    switch self {
    case .glutenFree: return "GLUTEN_FREE"
    case .mealWorthy: return "MEAL_WORTHY"
    }
  }
}

enum RestroomType {
  case indoors
  case genderSeperated

  static func type(of restroomType: String) -> RestroomType? {
    switch restroomType {
    case "INDOORS": return .indoors
    case "GENDER_SEPARATED": return .genderSeperated
    default: return nil
    }
  }

  var dtoName: String {
    switch self {
    case .indoors: return "INDOORS"
    case .genderSeperated: return "GENDER_SEPARATED"
    }
  }
}
