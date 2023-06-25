//
//  PlaceResponseDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/25.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

struct PlaceResponseDTO: Decodable {
  let placeId: Int
  let name: String
  let coordinates: CoordinateDTO
  let address: AddressDTO?
  let openingHours: [OpeningHourResponseDTO]
  let phoneNumber: String?
  let electricOutletLevel: String?
  let hasCommunalTable: Bool?
  let capacityLevel: String?
  let imageUrls: [String]?
}

struct OpeningHourResponseDTO: Decodable {
  let dayOfWeek: String?
  let openingHourType: String?
  let openAt: TimeOffsetDTO?
  let closedAt: TimeOffsetDTO?
}

struct TimeOffsetDTO: Decodable {
  let hour: Int?
  let minute: Int?
}
