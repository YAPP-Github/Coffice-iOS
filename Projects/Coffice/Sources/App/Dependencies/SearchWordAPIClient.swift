//
//  SearchWordAPIClient.swift
//  coffice
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Dependencies
import Foundation
import Network

struct SearchWordAPIClient: DependencyKey {
  static var liveValue: SearchWordAPIClient = .liveValue

  func fetchRecentSearchWords() async throws -> [SearchWordResponseDTO] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/search-words"
    guard let request = urlComponents?.toURLRequest(method: .get)
    else { return .init() }
    let response: [SearchWordResponseDTO] = try await coreNetwork.dataTask(request: request)
    return response
  }

  func deleteRecentSearchWord(id: Int) async throws {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/search-words/\(id)"
    guard let request = urlComponents?.toURLRequest(method: .delete)
    else { return }
    _ = try await coreNetwork.dataTask(request: request)
    return
  }

  func deleteAllRecentSearchWords() async throws {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/search-words"
    guard let request = urlComponents?.toURLRequest(method: .delete)
    else { return }
    _ = try await coreNetwork.dataTask(request: request)
    return
  }

  func uploadRecentSearchWord(text: String?) async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/search-words"
    let requestValue = SearchWordUploadRequestValue(text: text)

    guard let requestBody = try? JSONEncoder().encode(requestValue.toDTO())
    else { throw CoreNetworkError.jsonEncodeFailed }

    guard let request = urlComponents?.toURLRequest(method: .post, httpBody: requestBody)
    else { throw CoreNetworkError.requestConvertFailed }

    return try await coreNetwork.dataTask(request: request)
  }
}

extension DependencyValues {
  var searchWordClient: SearchWordAPIClient {
    get { self[SearchWordAPIClient.self] }
    set { self[SearchWordAPIClient.self] = newValue }
  }
}
