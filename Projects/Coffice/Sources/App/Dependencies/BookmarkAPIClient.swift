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

  func fetchMyPlaces() async throws -> [PlaceResponseDTO] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me/places"
    guard let request = urlComponents?.toURLRequest(method: .get) else {
      throw CoreNetworkError.requestConvertFailed
    }
    let response: [PlaceResponseDTO] = try await coreNetwork.dataTask(request: request)
    return response
  }

  func addMyPlace(placeId: Int) async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me/places/\(placeId)"
    guard let request = urlComponents?.toURLRequest(method: .post) else {
      throw CoreNetworkError.requestConvertFailed
    }
    let response = try await coreNetwork.dataTask(request: request)
    return response
  }

  func deleteMyPlace(placeId: Int) async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me/places/\(placeId)"
    guard let request = urlComponents?.toURLRequest(method: .delete) else {
      throw CoreNetworkError.requestConvertFailed
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
