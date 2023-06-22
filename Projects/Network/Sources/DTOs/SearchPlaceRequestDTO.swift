//
//  SearchRequestDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct SearchPlaceRequestDTO: Encodable {
  public let searchText: String
  public let latitude: Double
  public let longitude: Double
  public let distance: Double
  public let pageSize: Int
  public let pageNumber: Int

  public init(searchText: String, latitude: Double, longitude: Double, distance: Double, pageSize: Int, pageNumber: Int) {
    self.searchText = searchText
    self.latitude = latitude
    self.longitude = longitude
    self.distance = distance
    self.pageSize = pageSize
    self.pageNumber = pageNumber
  }
}
