//
//  PlaceRequestDTO.swift
//  Network
//
//  Created by 천수현 on 2023/07/09.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct PlaceRequestDTO: Encodable {
  public let page: Int
  public let size: Int
  public let sort: String

  public init(page: Int, size: Int, sort: String) {
    self.page = page
    self.size = size
    self.sort = sort
  }
}
