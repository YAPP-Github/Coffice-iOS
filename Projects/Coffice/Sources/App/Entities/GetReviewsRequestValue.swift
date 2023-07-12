//
//  GetReviewsRequestValue.swift
//  coffice
//
//  Created by Min Min on 2023/07/13.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

struct GetReviewsRequestValue {
  let placeId: Int
  let pageSize: Int
  let lastSeenReviewId: Int?

  init(placeId: Int, pageSize: Int = 10, lastSeenReviewId: Int? = nil) {
    self.placeId = placeId
    self.pageSize = pageSize
    self.lastSeenReviewId = lastSeenReviewId
  }
}
