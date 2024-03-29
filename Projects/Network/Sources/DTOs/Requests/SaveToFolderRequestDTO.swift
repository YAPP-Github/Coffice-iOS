//
//  SaveToFolderRequestDTO.swift
//  Network
//
//  Created by 천수현 on 2023/07/03.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct SavePlacesRequestDTO: Encodable {
  public let postIds: [Int]

  public init(postIds: [Int]) {
    self.postIds = postIds
  }
}
