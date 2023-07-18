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
  static let dummy = Cafe(
    placeId: 0,
    name: "name",
    address: .init(address: "address", simpleAddress: "simpleAddress", postalCode: "00000"),
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
    openingInformation: nil,
    capcityLevel: nil,
    drinkTypes: nil,
    foodTypes: nil,
    restroomType: nil,
    isBookmarked: false
  )

  let id = UUID() // TODO: Identifiable 채택을 위한 임시 코드
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
  let openingInformation: OpeningInformation?
  let capcityLevel: CapacityLevel?
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
    openingInformation?.formattedString ?? "-"
  }

  var bookmarkImage: Image {
    return isBookmarked
    ? CofficeAsset.Asset.bookmarkFill40px.swiftUIImage
    : CofficeAsset.Asset.bookmarkLine40px.swiftUIImage
  }

  var hasCommunalTableText: String? {
    return (hasCommunalTable ?? false) ? "🪑 단체석" : nil
  }

  var capacityLevelText: String? {
    switch capcityLevel {
    case .high: return "🗄️ 대형카페"
    case .medium: return "🗄️ 중형카페"
    case .low: return "🗄️ 소형카페"
    default: return nil
    }
  }

  var electricOutletLevelText: String? {
    switch electricOutletLevel {
    case "MANY": return "🔌 콘센트 넉넉"
    case "SEVERAL": return "🔌 콘센트 보통"
    case "FEW": return "🔌 콘센트 부족"
    default: return nil
    }
  }
}

extension SearchPlaceResponseDTO {
  func toCafeEntity() -> Cafe {
    let openingInformation = openingHours?.isEmpty == true
    ? nil
    : OpeningInformation(dayOpenInformations: openingHours?.map { $0.toEntity() } ?? [])
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
      openingInformation: openingInformation,
      capcityLevel: CapacityLevel.level(of: capacityLevel ?? ""),
      drinkTypes: drinkTypes?.compactMap { DrinkType.type(of: $0) },
      foodTypes: foodTypes?.compactMap { FoodType.type(of: $0) },
      restroomType: restroomTypes?.compactMap { RestroomType.type(of: $0) },
      isBookmarked: archived ?? false
    )
  }
}

extension PlaceResponseDTO {
  func toCafeEntity() -> Cafe {
    let openingInformation = openingHours == nil
    ? nil
    : OpeningInformation(dayOpenInformations: openingHours?.map { $0.toEntity() } ?? [])
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
      openingInformation: openingInformation,
      capcityLevel: CapacityLevel.level(of: capacityLevel ?? ""),
      drinkTypes: drinkTypes?.compactMap { DrinkType.type(of: $0) },
      foodTypes: foodTypes?.compactMap { FoodType.type(of: $0) },
      restroomType: restroomTypes?.compactMap { RestroomType.type(of: $0) },
      isBookmarked: archived ?? false
    )
  }
}
