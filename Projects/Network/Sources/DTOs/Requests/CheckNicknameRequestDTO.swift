//
//  CheckNicknameRequestDTO.swift
//  Network
//
//  Created by 천수현 on 2023/07/16.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct CheckNicknameRequestDTO: Encodable {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}
