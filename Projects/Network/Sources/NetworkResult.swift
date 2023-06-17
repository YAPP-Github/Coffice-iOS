//
//  NetworkResult.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

struct NetworkResult<DTO: Decodable>: Decodable {
  let code: String
  let message: String
  let data: DTO
}
