//
//  ReviewUploadRequestDTO.swift
//  Network
//
//  Created by Min Min on 2023/07/13.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct ReviewUploadRequestDTO: Encodable {
  let placeId: Int
  let electricOutletLevel: String
  let wifiLevel: String
  let noiseLevel: String
  let content: String?

  public init(
    placeId: Int,
    electricOutletLevel: String,
    wifiLevel: String,
    noiseLevel: String,
    content: String?
  ) {
    self.placeId = placeId
    self.electricOutletLevel = electricOutletLevel
    self.wifiLevel = wifiLevel
    self.noiseLevel = noiseLevel
    self.content = content
  }
}
