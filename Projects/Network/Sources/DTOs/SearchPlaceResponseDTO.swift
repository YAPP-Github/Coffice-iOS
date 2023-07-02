//
//  SearchPlaceResponseDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct SearchPlaceResponseDTO: Decodable, Equatable {
  public let placeId: Int
  public let name: String
  public let coordinates: CoordinateDTO
  public let address: AddressDTO?
}

public struct CoordinateDTO: Decodable, Equatable {
  public let latitude: Double
  public let longitude: Double
}

public struct AddressDTO: Decodable, Equatable {
  public let value: String?
  public let postalCode: String?
}
