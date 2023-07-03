//
//  Coordinate+AddressDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct CoordinateDTO: Decodable {
  public let latitude: Double
  public let longitude: Double
}

public struct AddressDTO: Decodable, Equatable {
  public let value: String?
  public let postalCode: String?
}
