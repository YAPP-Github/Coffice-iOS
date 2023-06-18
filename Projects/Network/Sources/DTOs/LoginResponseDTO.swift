//
//  LoginResponseDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

public struct LoginResponseDTO: Decodable {
  public let accessToken: String
  public let member: MemberDTO
}
