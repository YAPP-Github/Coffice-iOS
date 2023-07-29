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

  func fetchReviews(
    requestValue: ReviewsRequestValue
  ) async throws -> ReviewsResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(requestValue.placeId)/reviews"
    urlComponents?.queryItems = [
      .init(name: "pageSize", value: "\(requestValue.pageSize)")
    ]
    if let lastSeenReviewId = requestValue.lastSeenReviewId {
      urlComponents?.queryItems?.append(.init(name: "lastSeenReviewId", value: "\(lastSeenReviewId)"))
    }

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    let response: (
      dto: ReviewsResponseDTO,
      hasNext: Bool
    ) = try await coreNetwork.pageableDataTask(request: request)
    return .init(
      reviews: response.dto.map { element -> Review in
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
      },
      hasNext: response.hasNext
    )
  }

  func uploadReview(requestValue: ReviewUploadRequestValue) async throws -> Review {
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

    let response: ReviewResponseDTO = try await coreNetwork.dataTask(request: request)
    return .init(
      reviewId: response.reviewId,
      memberId: response.member.memberId,
      memberName: response.member.name,
      electricOutletLevel: response.electricOutletLevel,
      wifiLevel: response.wifiLevel,
      noiseLevel: response.noiseLevel,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
      content: response.content
    )
  }

  func editReview(requestValue: ReviewEditRequestValue) async throws -> Review {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(requestValue.placeId)/reviews/\(requestValue.reviewId)"

    guard let requestBody = try? JSONEncoder().encode(requestValue.toDTO())
    else { throw CoreNetworkError.jsonEncodeFailed }

    guard let request = urlComponents?.toURLRequest(
      method: .put,
      httpBody: requestBody
    )
    else { throw CoreNetworkError.requestConvertFailed }

    let response: ReviewResponseDTO = try await coreNetwork.dataTask(request: request)
    return .init(
      reviewId: response.reviewId,
      memberId: response.member.memberId,
      memberName: response.member.name,
      electricOutletLevel: response.electricOutletLevel,
      wifiLevel: response.wifiLevel,
      noiseLevel: response.noiseLevel,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
      content: response.content
    )
  }

  func deleteReview(placeId: Int, reviewId: Int) async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(placeId)/reviews/\(reviewId)"

    guard let request = urlComponents?.toURLRequest(method: .delete)
    else { throw CoreNetworkError.requestConvertFailed }

    return try await coreNetwork.dataTask(request: request)
  }

  func reportReview(placeId: Int, reviewId: Int) async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(placeId)/reviews/\(reviewId)/report"

    guard let request = urlComponents?.toURLRequest(method: .post)
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
