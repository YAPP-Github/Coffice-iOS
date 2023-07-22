//
//  PlaceRequestValue.swift
//  coffice
//
//  Created by 천수현 on 2023/07/09.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct PlaceRequestValue {
  let name: String
  let page: Int
  let size: Int
  let sort: SortDescriptor
}

extension PlaceRequestValue {
  func toDTO() -> PlaceRequestDTO {
    return .init(page: page, size: size, sort: sort.name)
  }
}
