//
//  Cafe.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network
import SwiftUI

struct Cafe: Hashable, Identifiable {
  let id = UUID() // TODO: Identifiable 채택을 위한 임시 코드
  let placeId: Int
  let name: String
  let address: Address?
  let latitude: Double
  let longitude: Double
  let distanceFromUser: Double
  let phoneNumber: String?
  let electricOutletLevel: ElectricOutletLevel
  let hasCommunalTable: CafeGroupSeatLevel
  let imageUrls: [String]?
  let homepageUrl: String?
  let crowdednessList: [CrowdednessResponse]?
  let openingInformation: OpeningInformation?
  let capacityLevel: CapacityLevel
  let drinkTypes: [DrinkType]?
  let foodTypes: [FoodType]?
  let restroomType: [RestroomType]?
  var isBookmarked: Bool
}

extension Cafe {
  var openingStateTextColor: Color {
    openingInformation?.isOpened ?? false
    ? CofficeAsset.Colors.secondary1.swiftUIColor
    : CofficeAsset.Colors.grayScale7.swiftUIColor
  }

  var openingStateDescription: String {
    openingInformation?.isOpened ?? false
    ? "영업중" : "영업종료"
  }

  var todayRunningTimeDescription: String {
    openingInformation?.quickFormattedString ?? "-"
  }

  var bookmarkImage: Image {
    return isBookmarked
    ? CofficeAsset.Asset.bookmarkFill40px.swiftUIImage
    : CofficeAsset.Asset.bookmarkLine40px.swiftUIImage
  }
}

extension SearchPlaceResponseDTO {
  func toCafeEntity() -> Cafe {
    var openingInformation: OpeningInformation?
    if let openingHours, openingHours.isNotEmpty {
      openingInformation = OpeningInformation(
        dayOpenInformations: openingHours.map { $0.toEntity() }
      )
    }
    return .init(
      placeId: placeId,
      name: name,
      address: address?.toEntity(),
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      distanceFromUser: distance ?? 0,
      phoneNumber: phoneNumber,
      electricOutletLevel: ElectricOutletLevel.level(of: electricOutletLevel ?? ""),
      hasCommunalTable: CafeGroupSeatLevel.level(of: hasCommunalTable ?? false),
      imageUrls: imageUrls,
      homepageUrl: homepageUrl,
      crowdednessList: crowdednessList?.map { $0.toEntity() },
      openingInformation: openingInformation,
      capacityLevel: CapacityLevel.level(of: capacityLevel ?? ""),
      drinkTypes: drinkTypes?.compactMap { DrinkType.type(of: $0) },
      foodTypes: foodTypes?.compactMap { FoodType.type(of: $0) },
      restroomType: restroomTypes?.compactMap { RestroomType.type(of: $0) },
      isBookmarked: archived ?? false
    )
  }
}

extension PlaceResponseDTO {
  func toCafeEntity() -> Cafe {
    var openingInformation: OpeningInformation?
    if let openingHours, openingHours.isNotEmpty {
      openingInformation = OpeningInformation(
        dayOpenInformations: openingHours.map { $0.toEntity() }
      )
    }
    return .init(
      placeId: placeId,
      name: name,
      address: address?.toEntity(),
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      distanceFromUser: 0,
      phoneNumber: phoneNumber,
      electricOutletLevel: ElectricOutletLevel.level(of: electricOutletLevel ?? ""),
      hasCommunalTable: CafeGroupSeatLevel.level(of: hasCommunalTable ?? false),
      imageUrls: imageUrls,
      homepageUrl: homepageUrl,
      crowdednessList: crowdednessList?.map { $0.toEntity() },
      openingInformation: openingInformation,
      capacityLevel: CapacityLevel.level(of: capacityLevel ?? ""),
      drinkTypes: drinkTypes?.compactMap { DrinkType.type(of: $0) },
      foodTypes: foodTypes?.compactMap { FoodType.type(of: $0) },
      restroomType: restroomTypes?.compactMap { RestroomType.type(of: $0) },
      isBookmarked: archived ?? false
    )
  }
}

extension Cafe {
  static let dummy = Cafe(
    placeId: 0,
    name: "name",
    address: .init(address: "address", simpleAddress: "simpleAddress", postalCode: "00000"),
    latitude: 37,
    longitude: 125,
    distanceFromUser: 100,
    phoneNumber: "010-0000-0000",
    electricOutletLevel: .few,
    hasCommunalTable: .unknown,
    imageUrls: [],
    homepageUrl: nil,
    crowdednessList: nil,
    openingInformation: nil,
    capacityLevel: .unknown,
    drinkTypes: nil,
    foodTypes: nil,
    restroomType: nil,
    isBookmarked: false
  )
}
