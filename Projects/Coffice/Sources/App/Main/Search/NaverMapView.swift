//
//  NaverMapView.swift
//  Cafe
//
//  Created by sehooon on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import SwiftUI
import NMapsMap
import ComposableArchitecture

struct NaverMapView: UIViewRepresentable {
  @ObservedObject var viewStore: ViewStoreOf<CafeMapCore>
  let view = NMFNaverMapView()

  func makeUIView(context: Context) -> NMFNaverMapView {
    setupMap(view)
    view.mapView.addCameraDelegate(delegate: context.coordinator)
    return view
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
    if viewStore.executeRefreshMarker == .on {
      addMarker(uiView, viewStore.cafeList, coordinator: context.coordinator)
      DispatchQueue.main.async { viewStore.send(.updateExecuteState(.refreshMarker, .off)) }
    }

    if viewStore.executeMoveCurrentLocation == .on {
      moveCameraToLocation(viewStore.region, uiView)
      DispatchQueue.main.async { viewStore.send(.updateExecuteState(.moveCurrentLocation, .off)) }
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(target: self)
  }
}
// TODOs:
// [1] 화면 MaxZoom, MinZoom 정하기
// [2] 현재 cameraPosition에서 반경 계산
// [3] 카메라 이동 이벤트 추가
extension NaverMapView {
  func setupMap(_ view: NMFNaverMapView) {
    view.showScaleBar = false
    view.showZoomControls = false
    view.showLocationButton = false
    view.mapView.positionMode = .direction
    view.mapView.locationOverlay.hidden = false
    view.mapView.maxZoomLevel = 50
    view.mapView.minZoomLevel = 30
    moveCameraToLocation(viewStore.region, view)
  }

  func removeAllMarker() {
    for marker in viewStore.markerList {
      marker.mapView = nil
      marker.touchHandler = nil
    }
    viewStore.send(.clearMarkerList)
  }

  func addMarker(_ view: NMFNaverMapView, _ cafeList: [CafeMarkerData], coordinator: Coordinator) {
    removeAllMarker()
    for cafe in cafeList {
      let marker = NMFMarker()
      let infoWindow = NMFInfoWindow()
      marker.position = NMGLatLng(lat: cafe.latitude, lng: cafe.longitude)
      marker.mapView = view.mapView
      marker.iconImage = NMFOverlayImage(image: UIImage(systemName: "person")!)
      infoWindow.position = NMGLatLng(lat: cafe.latitude, lng: cafe.longitude)
      infoWindow.dataSource = coordinator
      marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
        if infoWindow.marker == nil {
          infoWindow.open(with: marker)
          debugPrint("infowindow Open")
        } else {
          infoWindow.close()
          debugPrint("infoWindow Close")
        }
        let location = CLLocationCoordinate2D(latitude: cafe.latitude, longitude: cafe.longitude)
        moveCameraToLocation(location, view)
        return true
      }
    }
  }

  func moveCameraToLocation(_ coordinate: CLLocationCoordinate2D, _ view: NMFNaverMapView) {
    let latitude = coordinate.latitude
    let longitude = coordinate.longitude
    let nowCameraPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 15)
    view.mapView.moveCamera(cameraUpdate)
    DispatchQueue.main.async { viewStore.send(.updateCameraPosition(nowCameraPosition)) }
  }
}

class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewOptionDelegate, NMFOverlayImageDataSource {
  var target: NaverMapView
  init(target: NaverMapView) {
    self.target = target
  }

  func view(with overlay: NMFOverlay) -> UIView {
    let view = CustomInfoWindowView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
    view.backgroundColor = .red
    return view
  }
}
