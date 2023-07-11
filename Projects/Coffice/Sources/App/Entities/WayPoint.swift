//
//  WayPoint.swift
//  coffice
//
//  Created by 천수현 on 2023/07/09.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct WayPoint: Equatable, Hashable {
  let id: Int
  let name: String
  let latitude: Double
  let longitude: Double
}

extension WayPointDTO {
  func toEntity() -> WayPoint {
    return .init(
      id: waypointId,
      name: name,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude
    )
  }
}
