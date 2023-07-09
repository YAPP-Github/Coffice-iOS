//
//  SortDescriptor.swift
//  coffice
//
//  Created by 천수현 on 2023/07/09.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum SortDescriptor {
  case ascending
  case descending

  var name: String {
    switch self {
    case .ascending:
      return "asc"
    case .descending:
      return "desc"
    }
  }
}
