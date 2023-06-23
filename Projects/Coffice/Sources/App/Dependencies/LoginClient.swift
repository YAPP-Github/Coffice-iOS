//
//  KakaoLoginClient.swift
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

struct LoginClient: DependencyKey {
  static var liveValue: LoginClient = .liveValue

  func login(loginType: LoginType, accessToken: String?) async throws -> LoginResponseDTO {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/login"
    guard let requestBody = try? JSONEncoder()
      .encode(LoginRequestDTO(accessToken: accessToken ?? "",
                              providerType: loginType.name,
                              providerUserId: UUID().uuidString)) else {
      throw LoginError.jsonEncodeFailed
    }
    guard let request = urlComponents?.toURLRequest(
      method: .post,
      httpBody: requestBody
    ) else {
      throw LoginError.emptyAccessToken
    }
    let response: LoginResponseDTO = try await coreNetwork.dataTask(request: request)
    return response
  }

  func fetchUserData() async throws -> User {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me"

    guard let request = urlComponents?.toURLRequest(method: .get)
    else { throw LoginError.emptyAccessToken }

    let response: MemberResponseDTO = try await coreNetwork.dataTask(request: request)
    return response.toEntity()
  }
}

extension DependencyValues {
  var loginClient: LoginClient {
    get { self[LoginClient.self] }
    set { self[LoginClient.self] = newValue }
  }
}
