//
//  Cafe.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct Cafe: Hashable {
  static let dummy = Cafe(
    placeId: 0,
    name: "name",
    address: .init(address: "address", postalCode: "00000"),
    latitude: 37,
    longitude: 125,
    distanceFromUser: 100,
    phoneNumber: "010-0000-0000",
    electricOutletLevel: "low",
    hasCommunalTable: nil,
    capacityLevel: nil,
    imageUrls: [],
    homepageUrl: nil,
    crowdednessList: nil,
    isOpened: nil,
    capcityLevel: nil,
    drinkTypes: nil,
    foodTypes: nil,
    restroomType: nil
  )

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
  let homepageUrl: String?
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
      homepageUrl: homepageUrl,
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
      homepageUrl: homepageUrl,
      crowdednessList: crowdednessList?.map { $0.toEntity() },
      isOpened: nil,
      capcityLevel: CapacityLevel.level(of: capacityLevel ?? ""),
      drinkTypes: drinkTypes?.compactMap { DrinkType.type(of: $0) },
      foodTypes: foodTypes?.compactMap { FoodType.type(of: $0) },
      restroomType: restroomTypes?.compactMap { RestroomType.type(of: $0) }
    )
  }
}
