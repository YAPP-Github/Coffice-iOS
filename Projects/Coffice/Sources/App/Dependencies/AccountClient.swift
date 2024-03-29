//
//  AccountClient.swift
//  coffice
//
//  Created by 천수현 on 2023/06/17.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Dependencies
import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import Network

struct AccountClient: DependencyKey {
  static var liveValue: AccountClient = .liveValue

  func login(loginType: LoginType, accessToken: String?) async throws -> LoginResponseDTO {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/login"
    guard let requestBody = try? JSONEncoder()
      .encode(
        LoginRequestDTO(
          authProviderType: loginType.name,
          authProviderUserId: accessToken ?? UUID().uuidString
        )
      ) else {
      throw CoreNetworkError.jsonEncodeFailed
    }
    guard let request = urlComponents?.toURLRequest(
      method: .post,
      httpBody: requestBody
    ) else {
      throw CoreNetworkError.requestConvertFailed
    }
    let response: LoginResponseDTO = try await coreNetwork.dataTask(request: request)
    KeychainManager.shared.addItem(
      key: loginType == .anonymous ?
      KeychainManager.anonymousTokenKey : KeychainManager.tokenKey,
      value: response.accessToken
    )
    return response
  }

  func fetchUserData() async throws -> User {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me"

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw CoreNetworkError.requestConvertFailed }

    let response: MemberResponseDTO = try await coreNetwork.dataTask(request: request)
    return response.toEntity()
  }

  func logout() async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/logout"

    guard let request = urlComponents?.toURLRequest(method: .post)
    else { throw CoreNetworkError.requestConvertFailed }

    let response = try await coreNetwork.dataTask(request: request)
    return response
  }

  func memberLeave() async throws -> HTTPURLResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/withdraw"

    guard let request = urlComponents?.toURLRequest(method: .post)
    else { throw CoreNetworkError.requestConvertFailed }

    let response = try await coreNetwork.dataTask(request: request)
    return response
  }
}

extension DependencyValues {
  var accountClient: AccountClient {
    get { self[AccountClient.self] }
    set { self[AccountClient.self] = newValue }
  }
}
