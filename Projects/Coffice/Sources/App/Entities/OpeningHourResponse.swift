//
//  OpeningHourResponse.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

public struct OpeningHourResponse: Equatable {
  public let dayOfWeek: String?
  public let openingHourType: String?
  public let openedAt: TimeOffset?
  public let closedAt: TimeOffset?
}

extension OpeningHourResponseDTO {
  func toEntity() -> OpeningHourResponse {
    return .init(
      dayOfWeek: dayOfWeek,
      openingHourType: openingHourType,
      openedAt: openedAt?.toEntity(),
      closedAt: closedAt?.toEntity()
    )
  }
}
