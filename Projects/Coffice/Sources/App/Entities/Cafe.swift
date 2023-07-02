//
//  Cafe.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

/*
 public let placeId: Int
 public let name: String
 public let coordinates: CoordinateDTO
 public let address: AddressDTO?
 public let homepageUrl: String?
 public let openingHours: [OpeningHourResponseDTO]?
 public let phoneNumber: String?
 public let electricOutletLevel: String?
 public let hasCommunalTable: Bool?
 public let capacityLevel: String?
 public let imageUrls: [String]?
 public let crowdednessList: [CrowdednessResponse]?
 public let drinkTypes: [String]?
 public let foodTypes: [String]?
 public let restroomTypes: [String]?
 public let distance: Double?
 */
struct Cafe {
  let placeId: Int
  let name: String
  let address: Address?
  let latitude: Double
  let longitude: Double
  let distanceFromUser: Double
  let phoneNumber: String?
  let electricOutletLevel: String?
  let hasCommunalTable: Bool?
  let capacityLevel: String?
  let imageUrls: [String]?
  let crowdednessList: [CrowdednessResponse]?
  let isOpened: Bool?
  let capcityLevel: CapacityLevel?
  let drinkTypes: [DrinkType]?
  let foodTypes: [FoodType]?
  let restroomType: [RestroomType]?
}

extension SearchPlaceResponseDTO {
  func toCafeEntity() -> Cafe {
    return .init(
      placeId: placeId,
      name: name,
      address: address?.toEntity(),
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      distanceFromUser: distance ?? 0,
      phoneNumber: phoneNumber,
      electricOutletLevel: electricOutletLevel,
      hasCommunalTable: hasCommunalTable,
      capacityLevel: capacityLevel,
      imageUrls: imageUrls,
      crowdednessList: crowdednessList?.map { $0.toEntity() },
      isOpened: nil,
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
      placeId: placeId,
      name: name,
      address: address?.toEntity(),
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      distanceFromUser: 0,
      phoneNumber: phoneNumber,
      electricOutletLevel: electricOutletLevel,
      hasCommunalTable: hasCommunalTable,
      capacityLevel: capacityLevel,
      imageUrls: imageUrls,
      crowdednessList: crowdednessList?.map { $0.toEntity() },
      isOpened: nil,
      capcityLevel: CapacityLevel.level(of: capacityLevel ?? ""),
      drinkTypes: drinkTypes?.compactMap { DrinkType.type(of: $0) },
      foodTypes: foodTypes?.compactMap { FoodType.type(of: $0) },
      restroomType: restroomTypes?.compactMap { RestroomType.type(of: $0) }
    )
  }
}
