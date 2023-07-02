//
//  Cafe.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct Cafe {
  let address: Address?
  let name: String
  let latitude: Double
  let longitude: Double
  let distance: Double
  let isOpened: Bool?
  let hasCommunalTable: Bool?
  let capcityLevel: CapacityLevel?
  let drinkTypes: [DrinkType]?
  let foodTypes: [FoodType]?
  let restroomType: [RestroomType]?
}

public struct Address {
  public let address: String?
  public let postalCode: String?
}

extension AddressDTO {
  func toEntity() -> Address {
    return .init(address: value, postalCode: postalCode)
  }
}

extension SearchPlaceResponseDTO {
  func toCafeEntity() -> Cafe {
    return .init(
      address: address?.toEntity(),
      name: name,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      distance: distance ?? 0,
      isOpened: false,
      hasCommunalTable: hasCommunalTable,
      capcityLevel: CapacityLevel.level(of: capacityLevel ?? ""),
      drinkTypes: drinkTypes?.compactMap { DrinkType.type(of: $0) },
      foodTypes: foodTypes?.compactMap { FoodType.type(of: $0) },
      restroomType: restroomTypes?.compactMap { RestroomType.type(of: $0) }
    )
  }
}

extension PlaceResponseDTO {
  func toCafeEntity() -> Cafe {
    return .init(
      address: address?.toEntity(),
      name: name, latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      distance: 0,
      isOpened: false, hasCommunalTable: hasCommunalTable,
      capcityLevel: CapacityLevel.level(of: capacityLevel ?? ""),
      drinkTypes: drinkTypes?.compactMap { DrinkType.type(of: $0) },
      foodTypes: foodTypes?.compactMap { FoodType.type(of: $0) },
      restroomType: restroomTypes?.compactMap { RestroomType.type(of: $0) }
    )
  }
}
