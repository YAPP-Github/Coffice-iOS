//
//  CustomInfoWindowDataSource.swift
//  coffice
//
//  Created by jaeseunghan on 2023/10/15.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import NMapsMap
import UIKit

class CustomInfoWindowDataSource: NSObject, NMFOverlayImageDataSource {

  func view(with overlay: NMFOverlay) -> UIView {
    if let infoWindow = overlay as? NMFInfoWindow {
      var mapMarkerData: MapMarkerData?
      if let marker = infoWindow.marker {
        mapMarkerData = marker.userInfo["data"] as? MapMarkerData
      } else {
        mapMarkerData = infoWindow.userInfo["data"] as? MapMarkerData
      }
      guard let mapType = mapMarkerData?.type else {
        print("마커 생성 불가 : MapType이 명확하지 않음")
        return UIView()
      }

      switch mapType {
      case .cluster:
        //                Log.debug("cluster 뷰 만들기 시작")
        guard let mapCount = mapMarkerData?.count else {
          print("마커 생성 불가 : MapCount가 명확하지 않음")
          return UIView()
        }
        let radius: CGFloat = 18 + CGFloat(2 * log2(Double(mapCount)))
        let clusteredMarkerView = ClusteredMarkerView(
          frame: CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius),
          count: mapCount
        )
        clusteredMarkerView.layoutIfNeeded()
        return clusteredMarkerView
      case .leaf:
        let leafMarkerView = LeafMarkerView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        leafMarkerView.layoutIfNeeded()
        return leafMarkerView
      }
    }
    return UIView()
  }
}
