//
//  BoundingBox.swift
//  coffice
//
//  Created by jaeseunghan on 2023/10/15.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import UIKit
import MapKit
import NMapsMap

struct BoundingBox {

  let xSouthWest: CGFloat
  let ySouthWest: CGFloat
  let xNorthEast: CGFloat
  let yNorthEast: CGFloat

  // 클러스터 될 영역의 박스를 설정한다.
  static func mapRectToBoundingBox(mapRect: NMGLatLngBounds) -> BoundingBox {

    let minLat = mapRect.southWest.lat
    let maxLat = mapRect.northEast.lat

    let minLon = mapRect.southWest.lng
    let maxLon = mapRect.northEast.lng

    return BoundingBox(
      xSouthWest: CGFloat(minLon),
      ySouthWest: CGFloat(minLat),
      xNorthEast: CGFloat(maxLon),
      yNorthEast: CGFloat(maxLat)
    )
  }

  // 마커가 박스 영역 안에 포함되는지 확인한다.
  func containsCoordinate(coordinate: NMGLatLng) -> Bool {

    let isContainedInX = self.xSouthWest <= CGFloat(coordinate.lng) && CGFloat(coordinate.lng) <= self.xNorthEast
    let isContainedInY = self.ySouthWest <= CGFloat(coordinate.lat) && CGFloat(coordinate.lat) <= self.yNorthEast

    return (isContainedInX && isContainedInY)
  }

  // 셀이 박스 영역 안에 포함되는지 확인한다.
  func intersectsWithBoundingBox(boundingBox: BoundingBox) -> Bool {

    return (xSouthWest <= boundingBox.xNorthEast && xNorthEast >= boundingBox.xSouthWest &&
            ySouthWest <= boundingBox.yNorthEast && yNorthEast >= boundingBox.ySouthWest)
  }
}
