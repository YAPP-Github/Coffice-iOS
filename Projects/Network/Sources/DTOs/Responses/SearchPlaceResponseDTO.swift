//
//  PlaceResponseDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/25.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct SearchPlaceResponseDTO: Decodable {
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
}

public struct OpeningHourResponseDTO: Decodable {
  public let dayOfWeek: String?
  public let openingHourType: String?
  public let openedAt: TimeOffsetDTO?
  public let closedAt: TimeOffsetDTO?
}

public struct TimeOffsetDTO: Decodable {
  public let hour: Int?
  public let minute: Int?
}

public struct CrowdednessResponse: Decodable {
  public let weekDayType: String?
  public let dayTimeType: String?
  public let crowdednessLevel: String?
}
