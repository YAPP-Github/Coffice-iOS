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

struct NaverMapView {
  @ObservedObject var viewStore: ViewStoreOf<CafeMapCore>
  static let storage = NaverMapViewStorage()

  init(viewStore: ViewStoreOf<CafeMapCore>) {
    self.viewStore = viewStore
  }
}

final class NaverMapViewStorage {
  var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var markers: [NMFMarker] = []
  var cafes: [CafeMarkerData] = []
  let iconImage = CofficeAsset.Asset.mapPinFill24px.image
}

extension NaverMapView: UIViewRepresentable {
  func makeUIView(context: Context) -> NMFNaverMapView {
    let naverMapView = NMFNaverMapView()
    naverMapView.showScaleBar = false
    naverMapView.showZoomControls = false
    naverMapView.showLocationButton = false
    naverMapView.mapView.positionMode = .direction
    naverMapView.mapView.locationOverlay.hidden = false
    naverMapView.mapView.maxZoomLevel = 50
    naverMapView.mapView.minZoomLevel = 30
    naverMapView.mapView.addCameraDelegate(delegate: context.coordinator)
    return naverMapView
  }

  func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
    if NaverMapView.storage.location != viewStore.state.region {
      let nmgLocation = NMGLatLng(lat: viewStore.state.region.latitude, lng: viewStore.state.region.longitude)
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: 15)
      DispatchQueue.main.async {
        uiView.mapView.moveCamera(cameraUpdate)
      }
    }

    if NaverMapView.storage.cafes != viewStore.state.cafeList {
      NaverMapView.storage.cafes = viewStore.state.cafeList
      DispatchQueue.main.async {
        addMarker(naverMapView: uiView, cafeList: viewStore.cafeList, coordinator: context.coordinator)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(target: self)
  }
}

extension NaverMapView {
  func removeAllMarkers() {
    for marker in NaverMapView.storage.markers {
      marker.touchHandler = nil
      marker.mapView = nil
    }
    NaverMapView.storage.markers.removeAll()
  }

  func addMarker(naverMapView: NMFNaverMapView, cafeList: [CafeMarkerData], coordinator: Coordinator) {
    removeAllMarkers()
    for cafe in cafeList {
      let marker = NMFMarker()
      marker.position = NMGLatLng(lat: cafe.latitude, lng: cafe.longitude)
      marker.iconImage = NMFOverlayImage(image: CofficeAsset.Asset.mapPinFill24px.image)
      marker.width = 20
      marker.height = 20

      let infoWindow = NMFInfoWindow()
      infoWindow.position = NMGLatLng(lat: cafe.latitude, lng: cafe.longitude)
      infoWindow.dataSource = coordinator

      marker.touchHandler = { [weak infoWindow] (overlay: NMFOverlay) -> Bool in
        if infoWindow?.marker == nil {
          infoWindow?.open(with: marker)
          debugPrint("infowindow Open")
        } else {
          infoWindow?.close()
          debugPrint("infoWindow Close")
        }

        moveCameraTo(naverMapView: naverMapView,
                     location: .init(latitude: cafe.latitude, longitude: cafe.longitude))
        return true
      }
      marker.mapView = naverMapView.mapView
      NaverMapView.storage.markers.append(marker)
    }
  }

  func moveCameraTo(naverMapView: NMFNaverMapView, location: CLLocationCoordinate2D) {
    let nmgLocation = NMGLatLng(lat: location.latitude, lng: location.longitude)
    let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation)
    naverMapView.mapView.moveCamera(cameraUpdate)
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
