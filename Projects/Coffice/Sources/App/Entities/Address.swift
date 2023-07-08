//
//  Address.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

public struct Address: Hashable {
  public let address: String?
  public let simpleAddress: String?
  public let postalCode: String?
}

extension AddressDTO {
  func toEntity() -> Address {
    return .init(address: value, simpleAddress: simpleValue, postalCode: postalCode)
  }
}
