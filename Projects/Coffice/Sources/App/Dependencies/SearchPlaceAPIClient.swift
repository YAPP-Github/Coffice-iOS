//
//  PlaceAPIClient.swift
//  coffice
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Dependencies
import Foundation
import Network

struct SearchPlaceAPIClient: DependencyKey {
  static var liveValue: SearchPlaceAPIClient = .liveValue

  func searchPlaces(requestValue: SearchPlaceRequestValue) async throws -> CafeSearchResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/search"
    guard let requestBody = try? JSONEncoder()
      .encode(requestValue.toDTO()) else {
      throw CoreNetworkError.jsonEncodeFailed
    }
    guard let request = urlComponents?.toURLRequest(
      method: .post,
      httpBody: requestBody
    ) else {
      throw CoreNetworkError.requestConvertFailed
    }
    let response: (dto: [SearchPlaceResponseDTO], hasNext: Bool) = try await coreNetwork
      .pageableDataTask(request: request)
    let cafeSearchResponse = CafeSearchResponse(
      cafes: response.dto.map { $0.toCafeEntity() },
      filters: requestValue.filters,
      hasNext: response.hasNext
    )

    return cafeSearchResponse
  }

  func fetchPlaces(requestValue: PlaceRequestValue) async throws -> CafeSearchResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places"
    urlComponents?.queryItems = [
      .init(name: "name", value: requestValue.name),
      .init(name: "page", value: String(requestValue.page)),
      .init(name: "sort", value: requestValue.sort.name)
    ]
    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    let response: (dto: [SearchPlaceResponseDTO], hasNext: Bool) = try await coreNetwork
      .pageableDataTask(request: request)
    let cafeSearchResponse = CafeSearchResponse(
      cafes: response.dto.map { $0.toCafeEntity() },
      filters: nil,
      hasNext: response.hasNext
    )

    return cafeSearchResponse
  }

  func fetchPlace(placeId: Int) async throws -> Cafe {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/places/\(placeId)"

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    let response: PlaceResponseDTO = try await coreNetwork.dataTask(request: request)
    return response.toCafeEntity()
  }

  func fetchWaypoints(name: String) async throws -> [WayPoint] {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/waypoints"
    urlComponents?.queryItems = [
      .init(name: "name", value: name)
    ]
    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    let response: (dto: [WayPointDTO], hasNext: Bool) = try await coreNetwork
      .pageableDataTask(request: request)

    return response.dto.map { $0.toEntity() }
  }
}

extension DependencyValues {
  var placeAPIClient: SearchPlaceAPIClient {
    get { self[SearchPlaceAPIClient.self] }
    set { self[SearchPlaceAPIClient.self] = newValue }
  }
}

extension SearchPlaceAPIClient {
  enum SortDescriptor {
    case ascending
    case descending

    var name: String {
      switch self {
      case .ascending:
        return "asc"
      case .descending:
        return "desc"
      }
    }
  }
}
