//
//  NetworkException.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

struct NetworkException: Decodable {
  let code: String
  let message: String
}
