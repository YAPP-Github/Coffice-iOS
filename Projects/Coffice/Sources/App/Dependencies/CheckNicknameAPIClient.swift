//
//  CheckNicknameAPIClient.swift
//  coffice
//
//  Created by 천수현 on 2023/07/16.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Dependencies
import Foundation
import Network

struct CheckNicknameAPIClient: DependencyKey {
  static var liveValue: CheckNicknameAPIClient = .liveValue

  func checkNickname(nickName: String) async throws -> CheckNicknameResponse {
    let coreNetwork = CoreNetwork.shared
    var urlComponents = URLComponents(string: coreNetwork.baseURL)
    urlComponents?.path = "/api/v1/members/me/name"

    guard let requestBody = try? JSONEncoder().encode(CheckNicknameRequestDTO(name: nickName))
    else { throw CoreNetworkError.jsonEncodeFailed }

    guard let request = urlComponents?.toURLRequest(
      method: .put,
      httpBody: requestBody
    ) else {
      throw CoreNetworkError.requestConvertFailed
    }

    let result: NetworkResult<MemberResponseDTO> = try await coreNetwork.networkResult(request: request)
    return CheckNicknameResponse.response(of: result)
  }
}

extension DependencyValues {
  var checkNicknameAPIClient: CheckNicknameAPIClient {
    get { self[CheckNicknameAPIClient.self] }
    set { self[CheckNicknameAPIClient.self] = newValue }
  }
}
