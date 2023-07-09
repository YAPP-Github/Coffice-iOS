//
//  CafeSearchResponse.swift
//  coffice
//
//  Created by 천수현 on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

struct CafeSearchResponse: Equatable {
  let cafes: [Cafe]
  let filters: CafeSearchFilters?
  let hasNext: Bool
}
