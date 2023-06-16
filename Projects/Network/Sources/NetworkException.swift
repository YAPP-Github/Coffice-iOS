//
//  NetworkException.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

struct NetworkException: Decodable {
  let timestamp: String
  let status: Int
  let error: String
  let message: String
  let path: String
}
