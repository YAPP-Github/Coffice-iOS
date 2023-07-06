//
//  MapMarker.swift
//  coffice
//
//  Created by 천수현 on 2023/07/06.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import NMapsMap

final class MapMarker: NMFMarker {
  let cafe: Cafe
  var markerType: MapMarkerType {
    didSet {
      width = markerType.width
      height = markerType.height
      iconImage = NMFOverlayImage(image: markerType.image)
    }
  }

  init(
    cafe: Cafe,
    markerType: MapMarkerType,
    position: NMGLatLng
  ) {
    self.cafe = cafe
    self.markerType = markerType
    super.init()
    self.position = position
    width = markerType.width
    height = markerType.height
    iconImage = NMFOverlayImage(image: markerType.image)
  }
}
