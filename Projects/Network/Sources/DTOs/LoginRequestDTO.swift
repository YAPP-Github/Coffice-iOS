//
//  LoginRequestDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/17.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct LoginRequestDTO: Encodable {
  public let authProviderType: String
  public let authProviderUserId: String

  public init(authProviderType: String, authProviderUserId: String) {
    self.authProviderType = authProviderType
    self.authProviderUserId = authProviderUserId
  }
}
