//
//  CafeDetailNaverMapView.swift
//  coffice
//
//  Created by 천수현 on 2023/07/12.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import NMapsMap
import SwiftUI

struct CafeDetailNaverMapView {
  @ObservedObject var viewStore: ViewStoreOf<CafeDetail>

  init(viewStore: ViewStoreOf<CafeDetail>) {
    self.viewStore = viewStore
  }
}

extension CafeDetailNaverMapView: UIViewRepresentable {
  func makeUIView(context: Context) -> NMFNaverMapView {
    let naverMapView = NMFNaverMapView()
    naverMapView.showScaleBar = false
    naverMapView.showZoomControls = false
    naverMapView.showLocationButton = false
    naverMapView.mapView.positionMode = .direction
    naverMapView.mapView.locationOverlay.hidden = false
    naverMapView.mapView.allowsScrolling = false
    naverMapView.mapView.allowsZooming = false
    naverMapView.mapView.allowsRotating = false
    naverMapView.mapView.allowsTilting = false
    return naverMapView
  }

  func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
    if let cafe = viewStore.cafe {
      addMarker(
        naverMapView: uiView,
        latitude: cafe.latitude,
        longitude: cafe.longitude,
        coordinator: context.coordinator
      )
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(target: self)
  }
}

extension CafeDetailNaverMapView {
  func addMarker(naverMapView: NMFNaverMapView, latitude: Double, longitude: Double, coordinator: Coordinator) {
    let marker = NMFMarker(position: NMGLatLng(lat: latitude, lng: longitude))
    marker.iconImage = NMFOverlayImage(image: CofficeAsset.Asset.mapPinFill24px.image)
    marker.width = 24
    marker.height = 24
    marker.mapView = naverMapView.mapView
    let nmgLocation = NMGLatLng(lat: latitude, lng: longitude)
    let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: 15.5)
    naverMapView.mapView.moveCamera(cameraUpdate)
  }
}

extension CafeDetailNaverMapView {
  class Coordinator: NSObject, NMFMapViewOptionDelegate {
    var target: CafeDetailNaverMapView

    init(target: CafeDetailNaverMapView) {
      self.target = target
    }
  }
}
