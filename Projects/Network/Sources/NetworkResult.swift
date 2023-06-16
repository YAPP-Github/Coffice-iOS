//
//  NetworkResult.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

struct NetworkResult<DTO: Decodable>: Decodable {
  let message: String
  let status: Int
  let data: DTO
}
