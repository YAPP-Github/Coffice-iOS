//
//  CrowdednessResponse.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

public struct CrowdednessResponse {
  public let weekDayType: String?
  public let dayTimeType: String?
  public let crowdednessLevel: String?
}

extension CrowdednessResponseDTO {
  func toEntity() -> CrowdednessResponse {
    return .init(weekDayType: weekDayType, dayTimeType: dayTimeType, crowdednessLevel: crowdednessLevel)
  }
}
