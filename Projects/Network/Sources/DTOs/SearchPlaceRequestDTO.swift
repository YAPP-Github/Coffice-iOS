//
//  SearchRequestDTO.swift
//  Network
//
//  Created by 천수현 on 2023/06/22.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct SearchPlaceRequestDTO: Encodable {
  public let searchText: String?
  public let latitude: Double
  public let longitude: Double
  public let distance: Double
  public let open: Bool?
  public let hasCommunalTable: Bool?
  public let capcityLevel: [String]?
  public let drinkType: [String]?
  public let foodType: [String]?
  public let pageSize: Int
  public let pageNumber: Int

  public init(searchText: String?, latitude: Double, longitude: Double, distance: Double, open: Bool?, hasCommunalTable: Bool?, capcityLevel: [String]?, drinkType: [String]?, foodType: [String]?, pageSize: Int, pageNumber: Int) {
    self.searchText = searchText
    self.latitude = latitude
    self.longitude = longitude
    self.distance = distance
    self.open = open
    self.hasCommunalTable = hasCommunalTable
    self.capcityLevel = capcityLevel
    self.drinkType = drinkType
    self.foodType = foodType
    self.pageSize = pageSize
    self.pageNumber = pageNumber
  }
}
