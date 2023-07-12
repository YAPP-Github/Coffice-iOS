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

struct GetReviewsRequestValue {
  let placeId: Int
  let pageSize: Int
  let lastSeenReviewId: Int?

  init(placeId: Int, pageSize: Int = 10, lastSeenReviewId: Int? = nil) {
    self.placeId = placeId
    self.pageSize = pageSize
    self.lastSeenReviewId = lastSeenReviewId
  }
}

public struct GetReviewsRequestDTO: Encodable {
  public let pageSize: Int
  public let lastSeenReviewId: Int?
}

struct ReviewAPIClient: DependencyKey {
  static var liveValue: ReviewAPIClient = .liveValue

  func fetchReviews(
    requestValue: GetReviewsRequestValue
  ) async throws -> [ReviewResponse] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(requestValue.placeId)/reviews"
    urlComponents?.queryItems = [
      .init(name: "pageSize", value: "\(requestValue.pageSize)")
    ]

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    // TODO: 페이징 업데이트 로직 추가 구현 필요
    let response: (
      dto: [GetReviewResponseDTO],
      hasNext: Bool
    ) = try await coreNetwork.pageableDataTask(request: request)
    return response.dto.map { element -> ReviewResponse in
      return .init(
        reviewId: element.reviewId,
        memberId: element.member.memberId,
        memberName: element.member.name,
        electricOutletLevel: element.electricOutletLevel,
        wifiLevel: element.wifiLevel,
        noiseLevel: element.noiseLevel,
        createdAt: element.createdAt,
        updatedAt: element.updatedAt,
        content: element.content
      )
    }
  }

  func postReview(requestValue: PostReviewRequestValue) async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(requestValue.placeId)/reviews"

    guard let requestBody = try? JSONEncoder().encode(requestValue.toDTO())
    else { throw CoreNetworkError.jsonEncodeFailed }

    guard let request = urlComponents?.toURLRequest(
      method: .post,
      httpBody: requestBody
    )
    else { throw CoreNetworkError.requestConvertFailed }

    return try await coreNetwork.dataTask(request: request)
  }
}

extension DependencyValues {
  var reviewAPIClient: ReviewAPIClient {
    get { self[ReviewAPIClient.self] }
    set { self[ReviewAPIClient.self] = newValue }
  }
}
