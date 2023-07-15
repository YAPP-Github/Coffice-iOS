//
//  ReviewEditRequestValue.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/14.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct ReviewEditRequestValue {
  let placeId: Int
  let reviewId: Int
  let electricOutletOption: ReviewOption.OutletOption
  let wifiOption: ReviewOption.WifiOption
  let noiseOption: ReviewOption.NoiseOption
  let content: String
}

extension ReviewEditRequestValue {
  func toDTO() -> ReviewEditRequestDTO {
    .init(
      placeId: placeId,
      reviewId: reviewId,
      electricOutletLevel: electricOutletOption.dtoName,
      wifiLevel: wifiOption.dtoName,
      noiseLevel: noiseOption.dtoName,
      content: content
    )
  }
}
