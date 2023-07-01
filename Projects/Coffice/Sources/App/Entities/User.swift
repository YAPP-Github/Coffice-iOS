//
//  User.swift
//  coffice
//
//  Created by 천수현 on 2023/06/23.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct User: Hashable {
  let id: Int
  let loginTypes: [LoginType]
  let name: String
}

extension MemberResponseDTO {
  func toEntity() -> User {
    return .init(
      id: memberId,
      loginTypes: authProviders.map {
        LoginType.type(of: $0.authProviderType)
      },
      name: name)
  }
}
