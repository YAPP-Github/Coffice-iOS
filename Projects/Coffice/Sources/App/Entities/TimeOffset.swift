//
//  TimeOffset.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

public struct TimeOffset: Equatable {
  public let hour: Int?
  public let minute: Int?
}

extension String {
  // TODO: String 형태로 내려오는 time을 변환하기
  func toEntity() -> TimeOffset {
    return .init(hour: 0, minute: 0)
  }
}
