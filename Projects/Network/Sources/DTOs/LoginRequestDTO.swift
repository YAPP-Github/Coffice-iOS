//
//  LoginRequestDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/17.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct LoginRequestDTO: Encodable {
  let accessToken: String
  let providerType: String
  let providerUserId: String

  public init(accessToken: String, providerType: String, providerUserId: String) {
    self.providerType = providerType
    self.providerUserId = providerUserId
  }
}
