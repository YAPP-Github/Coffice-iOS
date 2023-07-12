//
//  ReviewAPIClient.swift
//  coffice
//
//  Created by Min Min on 2023/07/11.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Dependencies
import Foundation
import Network

struct ReviewAPIClient: DependencyKey {
  static var liveValue: ReviewAPIClient = .liveValue

  func postReview(requestValue: PostReviewRequestValue) async throws {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(requestValue.placeId)/reviews"

    guard let requestBody = try? JSONEncoder()
      .encode(requestValue.toDTO())
    else { throw CoreNetworkError.jsonEncodeFailed }

    guard let request = urlComponents?.toURLRequest(
      method: .post,
      httpBody: requestBody
    )
    else { return }

    _ = try await coreNetwork.dataTask(request: request)
  }
}

extension DependencyValues {
  var reviewClient: ReviewAPIClient {
    get { self[ReviewAPIClient.self] }
    set { self[ReviewAPIClient.self] = newValue }
  }
}

