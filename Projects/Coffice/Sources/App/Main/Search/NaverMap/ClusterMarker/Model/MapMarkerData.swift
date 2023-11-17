//
//  MapMarkerData.swift
//  coffice
//
//  Created by 김현미 on 2023/11/16.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

struct MapMarkerData {

  var id: String?

  /* 데이터 내 설정된 lat, lng */
  var latitude: Double?
  var longitude: Double?

  var title: String?
  var subTitle: String?

  var count: Int?

  var type: MapType?

}
