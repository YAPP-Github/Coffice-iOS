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

  func fetchMyPlaces() async throws -> [Cafe] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me/places"
    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }
    let response: [PlaceResponseDTO] = try await coreNetwork.dataTask(request: request)
    return response.map { $0.toCafeEntity() }
  }

  func addMyPlace(placeId: Int) async throws {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me/places/\(placeId)"
    guard let request = urlComponents?.toURLRequest(method: .post)
    else { throw CoreNetworkError.jsonEncodeFailed }
    _ = try await coreNetwork.dataTask(request: request)
  }

  func deleteMyPlace(placeId: Int) async throws {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me/places/\(placeId)"
    guard let request = urlComponents?.toURLRequest(method: .delete)
    else { throw CoreNetworkError.requestConvertFailed }
    _ =  try await coreNetwork.dataTask(request: request)
  }

  func deleteMyPlaces(placeIds: [Int]) async throws {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me/places"
    guard let requestBody = try? JSONEncoder().encode(SavePlacesRequestDTO(postIds: placeIds))
    else { throw LoginError.jsonEncodeFailed }
    guard let request = urlComponents?.toURLRequest(method: .delete, httpBody: requestBody)
    else { throw LoginError.emptyAccessToken }
    _ = try await coreNetwork.dataTask(request: request)
  }
}

extension DependencyValues {
  var bookmarkClient: BookmarkAPIClient {
    get { self[BookmarkAPIClient.self] }
    set { self[BookmarkAPIClient.self] = newValue }
  }
}
