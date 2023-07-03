//
//  CoreNetwork.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

public enum CoreNetworkError: Error {
  case noAuthToken
  case invalidResponse(statusCode: Int)
  case sessionError
  case jsonDecodeFailed
  case jsonEncodeFailed
  case exceptionParseFailed
  case exception(errorMessage: String)
  case responseConvertFailed
  case requestConvertFailed
}

public protocol CoreNetworkInterface {
  var baseURL: String { get }
  func dataTask<DTO: Decodable>(request: URLRequest) async throws -> DTO
}

public final class CoreNetwork: CoreNetworkInterface {
  public static let shared = CoreNetwork()

  public var baseURL: String {
    guard let path = NetworkResources.bundle.path(forResource: "SecretAccessKey", ofType: "plist"),
          let dictionary = NSDictionary(contentsOfFile: path),
          let baseURL = dictionary["BASE_URL"] as? String else { return "" }
    return baseURL
  }

  public var token: String? {
    if let token = KeychainManager.shared.getItem(key: KeychainManager.tokenKey) {
      return token
    } else if let anonymousToken = KeychainManager.shared
      .getItem(key: KeychainManager.anonymousTokenKey) {
      return anonymousToken
    }
    return nil
  }

  private init() { }

  // TODO: Logger 제작 후 반영

  /// 반환값을 DTO로 변환할 수 있을때 사용하는 메서드입니다.
  public func dataTask<DTO: Decodable>(request: URLRequest) async throws -> DTO {
    let data = try await data(of: request)
    guard let dto = try? JSONDecoder().decode(NetworkResult<DTO>.self, from: data).data else {
      throw CoreNetworkError.jsonDecodeFailed
    }
    return dto
  }

  public func pageableDataTask<DTO: Decodable>(request: URLRequest) async throws -> (dto: DTO, hasNext: Bool) {
    let data = try await data(of: request)
    print(String(data: data, encoding: .utf8))
    guard let dto = try? JSONDecoder().decode(NetworkResult<DTO>.self, from: data).data else {
      throw CoreNetworkError.jsonDecodeFailed
    }
    guard let page = try? JSONDecoder().decode(NetworkResult<DTO>.self, from: data).page else {
      throw CoreNetworkError.jsonDecodeFailed
    }
    return (dto: dto, hasNext: false)
  }

  /// 반환값을 DTO로 변환하지 않을때 사용하는 메서드입니다.
  public func dataTask(request: URLRequest) async throws -> HTTPURLResponse {
    var request = request
    if let token = token {
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    } else {
      debugPrint("There is no jwt token")
    }
    let (data, response) = try await URLSession.shared.data(for: request)
    debugPrint("🌐 " + (request.httpMethod ?? "") + " : " + String(request.url?.absoluteString ?? ""))
    guard let httpResponse = response as? HTTPURLResponse else { throw CoreNetworkError.sessionError }
    guard 200...299 ~= httpResponse.statusCode else {
      guard let exception = try? JSONDecoder().decode(NetworkException.self, from: data) else {
        debugPrint("🚨 data: " + (String(data: data, encoding: .utf8) ?? ""))
        throw CoreNetworkError.exceptionParseFailed
      }
      debugPrint("🚨 status: \(httpResponse.statusCode) \n message: \(exception.message)")
      throw CoreNetworkError.exception(errorMessage: exception.message)
    }
    debugPrint("✅ status: \(httpResponse.statusCode)")
    return httpResponse
  }

  private func data(of request: URLRequest) async throws -> Data {
    var request = request
    if let token = token {
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    } else {
      debugPrint("There is no jwt token")
    }
    let (data, response) = try await URLSession.shared.data(for: request)
    debugPrint("🌐 " + (request.httpMethod ?? "") + " : " + String(request.url?.absoluteString ?? ""))
    guard let httpResponse = response as? HTTPURLResponse else {
      throw CoreNetworkError.sessionError
    }
    guard 200...299 ~= httpResponse.statusCode else {
      guard let exception = try? JSONDecoder().decode(NetworkException.self, from: data) else {
        debugPrint("🚨 data: " + (String(data: data, encoding: .utf8) ?? ""))
        throw CoreNetworkError.exceptionParseFailed
      }
      debugPrint("🚨 status: \(httpResponse.statusCode) \n message: \(exception.message)")
      throw CoreNetworkError.exception(errorMessage: exception.message)
    }
    debugPrint("✅ status: \(httpResponse.statusCode)")
    return data
  }
}
