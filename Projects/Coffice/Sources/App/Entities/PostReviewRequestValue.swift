//
//  PostReviewRequestValue.swift
//  coffice
//
//  Created by Min Min on 2023/07/13.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct PostReviewRequestValue {
  let placeId: Int
  let electricOutletOption: ReviewOption.OutletOption
  let wifiOption: ReviewOption.WifiOption
  let noiseOption: ReviewOption.NoiseOption
  let content: String
}

extension PostReviewRequestValue {
  func toDTO() -> PostReviewRequestDTO {
    .init(
      placeId: placeId,
      electricOutletLevel: electricOutletOption.dtoName,
      wifiLevel: wifiOption.dtoName,
      noiseLevel: noiseOption.dtoName,
      content: content
    )
  }
}
