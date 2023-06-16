//
//  HealthCheckClient.swift
//  Cafe
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation
import Dependencies
import Network

struct HealthCheckClient: DependencyKey {
  static var liveValue: HealthCheckClient = .liveValue

  func checkServerHealth() async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/hello"
    guard let request = urlComponents?.toURLRequest(method: .get) else {
      return .init()
    }
    let response = try await coreNetwork.dataTask(request: request)
    return response
  }
}

extension DependencyValues {
  var healthCheckClient: HealthCheckClient {
    get { self[HealthCheckClient.self] }
    set { self[HealthCheckClient.self] = newValue }
  }
}
