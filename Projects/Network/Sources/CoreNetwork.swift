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
  case jsonParseFailed
  case exceptionParseFailed
  case exception(errorMessage: String)
  case responseConvertFailed
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

  private var token: String? {
    if let token = KeychainManager.shared.getItem(key: "token") as? String {
      return token
    } else if let lookAroundToken = KeychainManager.shared.getItem(key: "lookAroundToken") as? String {
      return lookAroundToken
    }
    return nil
  }

  private init() { }

  // TODO: Logger 제작 후 반영

  /// 반환값을 DTO로 변환할 수 있을때 사용하는 메서드입니다.
  public func dataTask<DTO: Decodable>(request: URLRequest) async throws -> DTO {
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

    guard let dto = try? JSONDecoder().decode(NetworkResult<DTO>.self, from: data).data else {
      throw CoreNetworkError.jsonParseFailed
    }
    debugPrint("✅ status: \(httpResponse.statusCode)")
    return dto
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
}
