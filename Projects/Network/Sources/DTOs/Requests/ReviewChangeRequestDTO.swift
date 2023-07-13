//
//  ReviewChangeRequestDTO.swift
//  Network
//
//  Created by MinKyeongTae on 2023/07/14.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct ReviewChangeRequestDTO: Encodable {
  let placeId: Int
  let reviewId: Int
  let electricOutletLevel: String
  let wifiLevel: String
  let noiseLevel: String
  let content: String

  public init(
    placeId: Int,
    reviewId: Int,
    electricOutletLevel: String,
    wifiLevel: String,
    noiseLevel: String,
    content: String
  ) {
    self.placeId = placeId
    self.reviewId = reviewId
    self.electricOutletLevel = electricOutletLevel
    self.wifiLevel = wifiLevel
    self.noiseLevel = noiseLevel
    self.content = content
  }
}
