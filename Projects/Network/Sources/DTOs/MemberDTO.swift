//
//  MemberDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

public struct MemberDTO: Decodable {
  public let memberId: Int
  public let name: String
}
