//
//  BookmarkAPIClient.swift
//  coffice
//
//  Created by 천수현 on 2023/06/25.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Dependencies
import Foundation
import Network

struct BookmarkAPIClient: DependencyKey {
  static var liveValue: BookmarkAPIClient = .liveValue

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
  var bookmarkClient: BookmarkAPIClient {
    get { self[BookmarkAPIClient.self] }
    set { self[BookmarkAPIClient.self] = newValue }
  }
}
