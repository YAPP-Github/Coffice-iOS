//
//  SearchWordResponseDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct SearchWordResponseDTO: Decodable, Equatable {
  public let searchWordId: Int
  public let text: String
  public let createdAt: String
}
