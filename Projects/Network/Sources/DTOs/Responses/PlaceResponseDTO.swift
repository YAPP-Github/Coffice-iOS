//
//  PlaceResponseDTO.swift
//  Network
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct PlaceResponseDTO: Decodable {
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
  public let crowdednessList: [CrowdednessResponseDTO]?
  public let drinkTypes: [String]?
  public let foodTypes: [String]?
  public let restroomTypes: [String]?
  public let archived: Bool?
}
