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

  func fetchRecentSearchWords() async throws -> [String] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/search-words"
    guard let request = urlComponents?.toURLRequest(method: .get)
    else { return .init() }
    let response: [SearchWordResponseDTO] = try await coreNetwork.dataTask(request: request)
    return response.map { $0.text }
  }

  func deleteRecentSearchWord(id: Int) async throws {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/search-words/\(id)"
    guard let request = urlComponents?.toURLRequest(method: .delete)
    else { return }
    let response = try await coreNetwork.dataTask(request: request)
    return
  }

  func deleteAllRecentSearchWords() async throws {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/search-words"
    guard let request = urlComponents?.toURLRequest(method: .delete)
    else { return }
    let response = try await coreNetwork.dataTask(request: request)
    return
  }
}

extension DependencyValues {
  var searchWordClient: SearchWordAPIClient {
    get { self[SearchWordAPIClient.self] }
    set { self[SearchWordAPIClient.self] = newValue }
  }
}
