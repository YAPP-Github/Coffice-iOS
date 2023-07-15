//
//  NetworkResult.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

public struct NetworkResult<DTO: Decodable>: Decodable {
  public let code: String
  public let message: String
  public let data: DTO?
  public let page: PageResponse?

  public struct PageResponse: Decodable {
    public let hasNext: Bool?
  }
}
