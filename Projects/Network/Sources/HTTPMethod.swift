//
//  HTTPMethod.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

public enum HTTPMethod {
  case get
  case post
  case delete
  case patch
  case put

  var name: String {
    switch self {
    case .get:
      return "GET"
    case .post:
      return "POST"
    case .delete:
      return "DELETE"
    case .patch:
      return "PATCH"
    case .put:
      return "PUT"
    }
  }
}
