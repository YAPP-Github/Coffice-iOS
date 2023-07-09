//
//  WayPointDTO.swift
//  Network
//
//  Created by 천수현 on 2023/07/09.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct WayPointDTO: Decodable {
  public let waypointId: Int
  public let name: String
  public let coordinates: CoordinateDTO
}
