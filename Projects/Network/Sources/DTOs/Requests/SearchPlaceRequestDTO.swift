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
  public let openAroundTheClock: Bool?
  public let hasCommunalTable: Bool?
  public let capacityLevels: [String]?
  public let drinkTypes: [String]?
  public let foodTypes: [String]?
  public let restroomTypes: [String]?
  public let electricOutletLevels: [String]?

  public let pageSize: Int
  public let lastSeenDistance: Double?

  public init(
    searchText: String?,
    latitude: Double,
    longitude: Double,
    distance: Double,
    open: Bool?,
    openAroundTheClock: Bool?,
    hasCommunalTable: Bool?,
    capacityLevels: [String]?,
    drinkType: [String]?,
    foodType: [String]?,
    restroomTypes: [String]?,
    electricOutletLevels: [String]?,
    pageSize: Int,
    lastSeenDistance: Double?
  ) {
    self.searchText = searchText
    self.latitude = latitude
    self.longitude = longitude
    self.distance = distance
    self.open = open
    self.openAroundTheClock = openAroundTheClock
    self.hasCommunalTable = hasCommunalTable
    self.capacityLevels = capacityLevels
    self.drinkTypes = drinkType
    self.foodTypes = foodType
    self.restroomTypes = restroomTypes
    self.electricOutletLevels = electricOutletLevels
    self.pageSize = pageSize
    self.lastSeenDistance = lastSeenDistance
  }
}
