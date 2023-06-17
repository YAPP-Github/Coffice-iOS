//
//  URLComponentsExtension.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

public extension URLComponents {
  func toURLRequest(method: HTTPMethod, httpBody: Data? = nil, contentType: String = "application/json") -> URLRequest? {
    guard let url = url else { return nil }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.name
    if let httpBody {
      urlRequest.httpBody = httpBody
      urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
    }
    return urlRequest
  }
}
