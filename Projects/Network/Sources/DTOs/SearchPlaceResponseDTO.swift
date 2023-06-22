//
//  SearchPlaceResponseDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct SearchPlaceResponseDTO: Decodable {
  public let placeId: Int
  public let name: String
  public let coordinates: Coordinate
  public let address: Address?

  public struct Coordinate: Decodable {
    public let latitude: Double
    public let longitude: Double
  }

  public struct Address: Decodable {
    public let value: String
    public let postalCode: String
  }
}
