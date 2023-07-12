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

  func fetchReviews(placeId: Int) async throws -> [ReviewResponse] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(placeId)/reviews"

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    // TODO: 페이징 업데이트 로직 추가 구현 필요
    let response: (dto: GetReviewResponseDTO, hasNext: Bool) = try await coreNetwork.pageableDataTask(request: request)
    return response.dto.data.compactMap { datum -> ReviewResponse? in
      return .init(
        reviewId: datum.reviewId,
        memberId: datum.member.memberId,
        memberName: datum.member.name,
        electricOutletLevel: datum.electricOutletLevel,
        wifiLevel: datum.wifiLevel,
        noiseLevel: datum.noiseLevel,
        createdAt: datum.createdAt,
        updatedAt: datum.updatedAt,
        content: datum.content
      )
    }
  }

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
    else { throw CoreNetworkError.requestConvertFailed }

    _ = try await coreNetwork.dataTask(request: request)
  }
}

extension DependencyValues {
  var reviewAPIClient: ReviewAPIClient {
    get { self[ReviewAPIClient.self] }
    set { self[ReviewAPIClient.self] = newValue }
  }
}

