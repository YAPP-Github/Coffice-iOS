//
//  CafeFilters.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

struct CafeSearchFilters: Equatable {
  let capacityLevels: [CapacityLevel]?
  let drinkTypes: [DrinkType]?
  let foodTypes: [FoodType]?
  let restroomTypes: [RestroomType]?
  let electricOutletLevels: [ElectricOutletLevel]?
}
