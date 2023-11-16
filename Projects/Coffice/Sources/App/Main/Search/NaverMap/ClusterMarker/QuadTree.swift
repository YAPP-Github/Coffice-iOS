//
//  QuadTree.swift
//  coffice
//
//  Created by jaeseunghan on 2023/10/15.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import MapKit
import NMapsMap

class QuadTree {

  static let capacity = 4

  var markers = [NMFMarker]()
  var boundingBox: BoundingBox
  var isDivided = false

  private var northWest: QuadTree?
  private var northEast: QuadTree?
  private var southWest: QuadTree?
  private var southEast: QuadTree?

  init(boundingBox: BoundingBox) {
    self.boundingBox = boundingBox

  }

  deinit {
    self.markers.removeAll()
    isDivided = false

    northWest = nil
    northEast = nil
    southWest = nil
    southEast = nil
  }

  // 쿼드 트리 알고리즘을 적용 시킬 변수 초기화
  public func resetQuadTree() {
    self.markers.removeAll()
    isDivided = false

    northWest = nil
    northEast = nil
    southWest = nil
    southEast = nil

  }

  // 해당 바운드박스(노드) 내 마커들이 임계치보다 갯수가 많으면 4개의 사분면으로 분할하여 서브 바운드박스(노드)에 담아 넣음.
  // 이 과정을 재귀로 반복하여 임계치보다 작아질 때 까지 반복함.
  public func insertMarker(newMarker: NMFMarker) {

    guard self.boundingBox.containsCoordinate(coordinate: newMarker.position) else {

      return
    }
    if markers.count < QuadTree.capacity {

      markers.append(newMarker)
    } else {

      if northWest == nil {
        self.subdivideNode()
      }
      northWest?.insertMarker(newMarker: newMarker)
      northEast?.insertMarker(newMarker: newMarker)
      southWest?.insertMarker(newMarker: newMarker)
      southEast?.insertMarker(newMarker: newMarker)
    }
  }

  // 각 바운드박스(노드) 별로 해당되는 마커들의 리스트를 얻어온다.
  // 분할이 필요하다면 재귀형태로 파고들어 마커들의 리스트를 얻어온다.
  func queryRegion(searchInBoundingBox: BoundingBox, completion: ([NMFMarker]) -> Void) {

    guard searchInBoundingBox.intersectsWithBoundingBox(boundingBox: self.boundingBox) else {

      return
    }

    var totalMarkers = [NMFMarker]()
    for marker in self.markers {

      if searchInBoundingBox.containsCoordinate(coordinate: marker.position) {
        totalMarkers.append(marker)
      }

    }
    if self.isDivided {

      northEast?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (markers) in
        totalMarkers.append(contentsOf: markers)
      })
      northWest?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (markers) in
        totalMarkers.append(contentsOf: markers)
      })
      southEast?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (markers) in
        totalMarkers.append(contentsOf: markers)
      })
      southWest?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (markers) in
        totalMarkers.append(contentsOf: markers)
      })
    }
    completion(totalMarkers)
  }

  func getSubQuadTrees() -> [QuadTree] {
    if isDivided {
      return [northWest!, northEast!, southWest!, southEast!]
    } else {
      return []
    }
  }
}

extension QuadTree {

  private func subdivideNode() {
    self.isDivided = true
    let xMiddle = (boundingBox.xNorthEast+boundingBox.xSouthWest)/2.0
    let yMiddle = (boundingBox.yNorthEast+boundingBox.ySouthWest)/2.0

    self.northWest = QuadTree(boundingBox: BoundingBox(xSouthWest: boundingBox.xSouthWest, ySouthWest: yMiddle, xNorthEast: xMiddle, yNorthEast: boundingBox.yNorthEast))
    self.northEast = QuadTree(boundingBox: BoundingBox(xSouthWest: xMiddle, ySouthWest: yMiddle, xNorthEast: boundingBox.xNorthEast, yNorthEast: boundingBox.yNorthEast))
    self.southWest = QuadTree(boundingBox: BoundingBox(xSouthWest: boundingBox.xSouthWest, ySouthWest: boundingBox.ySouthWest, xNorthEast: xMiddle, yNorthEast: yMiddle))
    self.southEast = QuadTree(boundingBox: BoundingBox(xSouthWest: xMiddle, ySouthWest: boundingBox.ySouthWest, xNorthEast: boundingBox.xNorthEast, yNorthEast: yMiddle))

  }

}
