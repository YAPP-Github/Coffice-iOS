//
//  CafeFilterInformation.swift
//  coffice
//
//  Created by Min Min on 2023/07/06.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

/// 카페 필터 정보 공용 처리용 모델
struct CafeFilterInformation: Equatable {
  static var initialState: Self {
    .init()
  }
  static var mock: Self {
    .init(
      outletOptionSet: .init([.many]),
      runningTimeOptionSet: .init([.twentyFourHours]),
      spaceSizeOptionSet: .init([]),
      personnelOptionSet: .init([.groupSeat]),
      foodOptionSet: .init([.desert, .mealAvailable]),
      toiletOptionSet: .init([.indoors]),
      drinkOptionSet: .init([.soyMilk])
    )
  }

  var outletOptionSet: Set<CafeFilter.OutletOption> = []
  var runningTimeOptionSet: Set<CafeFilter.RunningTimeOption> = []
  var spaceSizeOptionSet: Set<CafeFilter.SpaceSizeOption> = []
  var personnelOptionSet: Set<CafeFilter.PersonnelOption> = []
  var foodOptionSet: Set<CafeFilter.FoodOption> = []
  var toiletOptionSet: Set<CafeFilter.ToiletOption> = []
  var drinkOptionSet: Set<CafeFilter.DrinkOption> = []
}
