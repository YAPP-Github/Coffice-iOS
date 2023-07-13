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

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    // TODO: 페이징 업데이트 로직 추가 구현 필요
    let response: (
      dto: ReviewsResponseDTO,
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

  func uploadReview(requestValue: ReviewUploadRequestValue) async throws -> HTTPURLResponse {
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

  func changeReview(requestValue: ReviewChangeRequestValue) async throws -> HTTPURLResponse {
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

    return try await coreNetwork.dataTask(request: request)
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
