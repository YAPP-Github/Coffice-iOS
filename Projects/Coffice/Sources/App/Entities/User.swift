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
  let loginType: LoginType
  let name: String
}

extension MemberResponseDTO {
  func toEntity() -> User {
    return User(id: memberId, loginType: LoginType.type(of: loginType ?? ""), name: name)
  }
}
