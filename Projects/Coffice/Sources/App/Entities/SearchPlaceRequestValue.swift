//
//  SearchPlaceRequestValue.swift
//  coffice
//
//  Created by 천수현 on 2023/06/30.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct SearchPlaceRequestValue {
  let searchText: String?
  let userLatitude: Double
  let userLongitude: Double
  let maximumSearchDistance: Double
  let isOpened: Bool?
  let hasCommunalTable: Bool?
  let filters: CafeSearchFilters?
  let pageSize: Int
  let pageableKey: PageableKey?
}

struct PageableKey {
  let lastCafeDistance: Double // 직전 검색 결과를 통해 받은 카페 목록 중 마지막 카페의 distance값
}

extension SearchPlaceRequestValue {
  func toDTO() -> SearchPlaceRequestDTO {
    return .init(
      searchText: searchText,
      latitude: userLatitude,
      longitude: userLongitude,
      distance: maximumSearchDistance,
      open: isOpened,
      hasCommunalTable: hasCommunalTable,
      capcityLevel: filters?.capacityLevels?.compactMap { $0.dtoName },
      drinkType: filters?.drinkTypes?.compactMap { $0.dtoName },
      foodType: filters?.foodTypes?.compactMap { $0.dtoName },
      restroomTypes: filters?.restroomTypes?.compactMap { $0.dtoName },
      electricOutletLevels: filters?.restroomTypes?.compactMap { $0.dtoName },
      pageSize: pageSize,
      lastSeenDistance: pageableKey?.lastCafeDistance
    )
  }
}
