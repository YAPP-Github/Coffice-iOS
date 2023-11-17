//
//  ClusterManager.swift
//  coffice
//
//  Created by jaeseunghan on 2023/10/15.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import UIKit
import MapKit
import NMapsMap

protocol ClusteringManagerDelegate: AnyObject {

  func displayMarkers(markersTuple: [(NMFMarker, NMFInfoWindow?)])
}

// quad tree 알고리즘으로 만든 지도 클러스터링 매니저 (구글 지도에 들어가는 알고리즘)
class ClusteringManager {

  private let infoWindowDataSource = CustomInfoWindowDataSource()

  weak var delegate: ClusteringManagerDelegate?

  private let quadTree: QuadTree!

  init(mapView: NMFMapView, frame: CGRect) {

    self.quadTree = QuadTree(
      boundingBox: BoundingBox.mapRectToBoundingBox(
        mapRect: mapView.projection.latlngBounds(
          fromViewBounds: frame
        )
      )
    )
  }

  // 클러스터링 세팅 초기화
  public func resetQuadTreeSetting(mapView: NMFMapView, frame: CGRect) {

    quadTree.resetQuadTree()
    quadTree.boundingBox = BoundingBox.mapRectToBoundingBox(
      mapRect: mapView.projection.latlngBounds(fromViewBounds: frame)
    )
  }

  // 클러스터링에 들어갈 마커 추가
  public func addMarkers(markers: [NMFMarker]) {

    for marker in markers {
      self.quadTree.insertMarker(newMarker: marker)
    }

  }

  // 클러스터링 실행
  public func runClustering(mapView: NMFMapView, frame: CGRect, zoomScale: Double) {

    guard !zoomScale.isInfinite else {
      return
    }

    // 클러스터링 된 마커 관련 튜플 배열 저장
    var clusterMarkers = [(NMFMarker, NMFInfoWindow?)]()

    // 현재 보여지는 지도의 각 꼭지점 좌표 값으로 최소 최대값을 계산
    let minXproj = mapView.projection.latlngBounds(fromViewBounds: frame).southWest.lng
    let maxXproj = mapView.projection.latlngBounds(fromViewBounds: frame).northEast.lng
    let minYproj = mapView.projection.latlngBounds(fromViewBounds: frame).southWest.lat
    let maxYproj = mapView.projection.latlngBounds(fromViewBounds: frame).northEast.lat

    // 전체 맵 기준으로 타일을 나누었을 경우 현재 보여지는 꼭지점이 어느 타일의 꼭지점에 해당하는지의 값
    // 스크롤 시에 랜덤하게 클러스터링 되는 부자연스러움을 줄이기 위해 실행
    var minX = minXproj
    var maxX = maxXproj
    var minY = minYproj
    var maxY = maxYproj

    // 현재 맵 기준 가로 좌표 길이
    let projectionWidth = Double(maxXproj - minXproj)

    // 현재 지도에서 몇등분 할지의 값
    let divCount = ClusteringManager.cellDivCountForZoomScale(zoomScale: zoomScale)

    // 타일의 크기
    let cellSizePoints = projectionWidth / Double(divCount)

    // 전체 지도 기준 타일로 나누었을 경우 현재 보여지는 꼭지점의 최소 값들과 그 꼭지점이 해당하는 타일에 대한 최소값의 차이를 계산
    // 122.37 31.43 은 전체 지도의 최소값을 의미함(MapTabViewController 에 지정해놈, 추후 전역변수로 뺄 값임.)
    let differX = (minXproj - 122.37).truncatingRemainder(dividingBy: cellSizePoints)
    let differY = (minYproj - 31.43).truncatingRemainder(dividingBy: cellSizePoints)

    // 만일 차이가 있다면 해당 값만큼 빼주고 최대 치에는 줄어든 만큼 타일 크기를 더해줌
    if differX > 0 {
      minX -= differX
      maxX = maxX - differX + cellSizePoints
    }

    if differY > 0 {
      minY -= differY
      maxY = maxY - differY + cellSizePoints

    }

    // 각 타일 별로 클러스터링 시작
    var yCoordinate = minY

    while yCoordinate<maxY {
      var xCoordinate = minX

      while xCoordinate<maxX {

        let sw = NMGLatLng(lat: yCoordinate, lng: xCoordinate)
        let ne = NMGLatLng(lat: yCoordinate + cellSizePoints, lng: xCoordinate + cellSizePoints)

        // 타일이 될 지역 계산
        let area = BoundingBox.mapRectToBoundingBox(mapRect: NMGLatLngBounds(southWest: sw, northEast: ne))

        // 각 타일 별로 quad tree 진행
        self.quadTree.queryRegion(searchInBoundingBox: area) { (markers) in

          // 해당 타일에 2개 이상일 경우 묶음
          if markers.count > 1 {

            let centerMarker = makeClusteredMarker(markers: markers, mapView: mapView)

            clusterMarkers.append(centerMarker)

            // 해당 타일에 1개 일 경우 끝단 마커 그대로 생성
          } else if markers.count == 1 {

            let leafMarker = makeLeafMarker(marker: markers.first!, mapView: mapView)

            clusterMarkers.append(leafMarker)
          }
        }
        xCoordinate+=cellSizePoints

      }
      yCoordinate+=cellSizePoints

    }
    //        Log.debug("clustering 끝")
    //        Log.info("클러스터링 완료 후 마커 수 : \(clusterMarkers.count)")
    DispatchQueue.main.async {
      self.delegate?.displayMarkers(markersTuple: clusterMarkers)
    }

  }

  // 클러스터링 된 마커의 Marker와 InfoWindow 튜플 배출
  private func makeClusteredMarker(markers: [NMFMarker], mapView: NMFMapView) -> (NMFMarker, NMFInfoWindow?) {
    var totalX = 0.0
    var totalY = 0.0

    for marker in markers {
      totalX += marker.position.lat
      totalY += marker.position.lng
    }
    let totalMarkers = markers.count

    var mapMarkerData = MapMarkerData()
    mapMarkerData.latitude = totalX
    mapMarkerData.longitude = totalY
    mapMarkerData.title = "\(markers.count) 개"
    mapMarkerData.type = MapType.cluster
    mapMarkerData.count = markers.count

    let centerMarker = NMFMarker()
    centerMarker.position = NMGLatLng(lat: totalX/Double(totalMarkers), lng: totalY/Double(totalMarkers))
    centerMarker.userInfo = [
      "data": mapMarkerData,
      "markers": markers
    ]
    //        centerMarker.touchHandler = { [weak self] (overlay:NMFOverlay) -> Bool in
    //
    //            return true
    //        }

    let infoWindow = NMFInfoWindow()
    infoWindow.position = NMGLatLng(lat: totalX/Double(totalMarkers), lng: totalY/Double(totalMarkers))
    infoWindow.userInfo = [
      "data": mapMarkerData
    ]
    infoWindow.dataSource = infoWindowDataSource

    infoWindow.touchHandler = { (overlay:NMFOverlay) -> Bool in
      let cameraUpdate = NMFCameraUpdate(scrollTo: centerMarker.position, zoomTo: mapView.zoomLevel)
      cameraUpdate.animation = .linear
      mapView.moveCamera(cameraUpdate)
      return true
    }

    return (centerMarker, infoWindow)
  }

  // 끝단 실제 마커의 Marker와 InfoWindow 튜플 배출
  private func makeLeafMarker(marker: NMFMarker, mapView: NMFMapView) -> (NMFMarker, NMFInfoWindow?) {

    let leafMarker = marker
    return (leafMarker, nil)
  }

}

extension ClusteringManager {
  class func cellDivCountForZoomScale(zoomScale: Double) -> Int {
    let zoomLevel = Int(zoomScale)

    // 네이버 지도에 맞게 대강 맞춘 값
    switch zoomLevel {
    case 0...8:
      return 2
    case 9...11:
      return 4
    case 12...14:
      return 5
    case 15...16:
      return 6
    case 17...20:
      return 8
    default:
      return 10
    }
  }
}
