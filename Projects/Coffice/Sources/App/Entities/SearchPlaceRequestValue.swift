//
//  SearchPlaceRequestValue.swift
//  coffice
//
//  Created by 천수현 on 2023/06/30.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct SearchPlaceRequestValue {
  let searchText: String?
  let latitude: Double
  let longitude: Double
  let distacne: Double
  let isOpened: Bool?
  let hasCommunalTable: Bool?
  let capcityLevel: [CapacityLevel]?
  let drinkTypes: [DrinkType]?
  let foodTypes: [FoodType]?
  let restroomTypes: [RestroomType]?
  let pageSize: Int

  enum CapacityLevel {
    case unknown
    case low
    case medium
    case high

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

    var dtoName: String {
      switch self {
      case .indoors: return "INDOORS"
      case .genderSeperated: return "GENDER_SEPARATED"
      }
    }
  }
}

extension SearchPlaceRequestValue {
  func toDTO() -> SearchPlaceRequestDTO {
    return .init(
      searchText: searchText,
      latitude: latitude,
      longitude: longitude,
      distance: distacne,
      open: isOpened,
      hasCommunalTable: hasCommunalTable,
      capcityLevel: capcityLevel?.compactMap { $0.dtoName },
      drinkType: drinkTypes?.compactMap { $0.dtoName },
      foodType: foodTypes?.compactMap { $0.dtoName },
      restroomTypes: restroomTypes?.compactMap { $0.dtoName },
      pageSize: pageSize,
      lastSeenDistacne: nil
    )
  }
}
