//
//  CLLocationCoordinate2D+Extensions.swift
//  coffice
//
//  Created by 천수현 on 2023/07/13.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}
