//
//  APIClient.swift
//  YappProject
//
//  Created by Min Min on 2023/05/13.
//

import Foundation
import Dependencies
import Network

// TODO: 추후 API Sample code 정리 필요
/// Sample Response
typealias CoffeeResponse = [Coffee]

struct Coffee: Decodable, Equatable {
  let title: String
  let description: String
}

struct APIClient: DependencyKey {
  static var liveValue: APIClient = .liveValue

  func requestData<Model: Decodable>(urlRequest: URLRequest) async throws -> Model {
    let (data, _) = try await URLSession.shared.data(for: urlRequest)
    let jsonData = try JSONDecoder().decode(Model.self, from: data)
    return jsonData
  }

  func getCoffees() async throws -> CoffeeResponse {
    let url = URL(string: "https://api.sampleapis.com/coffee/hot")!
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    return try await requestData(urlRequest: urlRequest)
  }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
