//
//  CafeFilterInformation.swift
//  coffice
//
//  Created by Min Min on 2023/07/06.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

/// 카페 필터 정보 공용 처리용 모델
struct CafeFilterInformation: Equatable {
  static let initialState: Self = .init()

  static var mock: Self {
    .init(
      outletOptionSet: .init([.many]),
      runningTimeOptionSet: .init([.twentyFourHours]),
      spaceSizeOptionSet: .init([]),
      personnelOptionSet: .init([.groupSeat]),
      foodOptionSet: .init([.desert, .mealAvailable]),
      toiletOptionSet: .init([.indoors]),
      drinkOptionSet: .init([.soyMilk])
    )
  }

  var outletOptionSet: Set<CafeFilter.OutletOption> = []
  var runningTimeOptionSet: Set<CafeFilter.RunningTimeOption> = []
  var spaceSizeOptionSet: Set<CafeFilter.SpaceSizeOption> = []
  var personnelOptionSet: Set<CafeFilter.PersonnelOption> = []
  var foodOptionSet: Set<CafeFilter.FoodOption> = []
  var toiletOptionSet: Set<CafeFilter.ToiletOption> = []
  var drinkOptionSet: Set<CafeFilter.DrinkOption> = []

  var isOpened: Bool {
    runningTimeOptionSet.contains(.running)
  }

  var openAroundTheClock: Bool {
    runningTimeOptionSet.contains(.twentyFourHours)
  }

  var cafeSearchFilters: CafeSearchFilters {
    let capacityLevels = CafeFilter.SpaceSizeOption.allCases.compactMap { option -> CapacityLevel? in
      guard spaceSizeOptionSet.contains(option)
      else { return nil }

      switch option {
      case .small:
        return .low
      case .medium:
        return .medium
      case .large:
        return .high
      }
    }

    let drinkTypes = CafeFilter.DrinkOption.allCases.compactMap { option -> DrinkType? in
      guard drinkOptionSet.contains(option)
      else { return nil }

      switch option {
      case .decaf:
        return .decaffeinated
      case .soyMilk:
        return .soyMilk
      }
    }

    let foodTypes = CafeFilter.FoodOption.allCases.compactMap { option -> FoodType? in
      guard foodOptionSet.contains(option)
      else { return nil }

      switch option {
      case .desert:
        return .glutenFree
      case .mealAvailable:
        return .mealWorthy
      }
    }

    let restroomTypes = CafeFilter.ToiletOption.allCases.compactMap { option -> RestroomType? in
      guard toiletOptionSet.contains(option)
      else { return nil }

      switch option {
      case .indoors:
        return .indoors
      case .genderSeparated:
        return .genderSeperated
      }
    }

    let electricOutletTypes = CafeFilter.OutletOption.allCases.compactMap { option -> ElectricOutletType? in
      guard outletOptionSet.contains(option)
      else { return nil }

      switch option {
      case .few:
        return .few
      case .several:
        return .several
      case .many:
        return .many
      }
    }

    return CafeSearchFilters(
      capacityLevels: capacityLevels,
      drinkTypes: drinkTypes,
      foodTypes: foodTypes,
      restroomTypes: restroomTypes,
      electricOutletLevels: electricOutletTypes
    )
  }

  var hasCommunalTable: Bool {
    guard let personnelOption = personnelOptionSet.first
    else { return false }

    switch personnelOption {
    case .groupSeat:
      return true
    }
  }

  mutating func resetFilterInformation() {
    outletOptionSet.removeAll()
    runningTimeOptionSet.removeAll()
    spaceSizeOptionSet.removeAll()
    personnelOptionSet.removeAll()
    foodOptionSet.removeAll()
    toiletOptionSet.removeAll()
    drinkOptionSet.removeAll()
  }
}
