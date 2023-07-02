//
//  TimeOffset.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

public struct TimeOffset {
  public let hour: Int?
  public let minute: Int?
}

extension TimeOffsetDTO {
  func toEntity() -> TimeOffset {
    return .init(hour: hour, minute: minute)
  }
}
