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
  var markers: [MapMarker] = []
  var selectedMarker: MapMarker? {
    didSet {
      if let oldValue {
        oldValue.width = 24
        oldValue.height = 24
        oldValue.iconImage = NMFOverlayImage(image: NaverMapView.storage.unselectedIconImage)
      }
      if let selectedMarker {
        selectedMarker.width = 36
        selectedMarker.height = 47
        selectedMarker.iconImage = NMFOverlayImage(image: NaverMapView.storage.selectedIconImage)
      }
    }
  }
  var cafes: [Cafe] = []
  let unselectedIconImage = CofficeAsset.Asset.markerUnselected24px.image
  let selectedIconImage = CofficeAsset.Asset.markerSelected3647px.image
}

extension NaverMapView: UIViewRepresentable {
  func makeUIView(context: Context) -> NMFNaverMapView {
    let naverMapView = NMFNaverMapView()
    naverMapView.showScaleBar = false
    naverMapView.showZoomControls = false
    naverMapView.showLocationButton = false
    naverMapView.mapView.positionMode = .direction
    naverMapView.mapView.locationOverlay.hidden = false
    naverMapView.mapView.maxZoomLevel = 20
    naverMapView.mapView.minZoomLevel = 12
    naverMapView.mapView.addCameraDelegate(delegate: context.coordinator)
    naverMapView.mapView.touchDelegate = context.coordinator
    moveCameraTo(naverMapView: naverMapView, location: viewStore.currentCameraPosition, zoomLevel: 15)
    return naverMapView
  }

  func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
    if viewStore.isMovingToCurrentPosition {
      let nmgLocation = NMGLatLng(
        lat: viewStore.currentCameraPosition.latitude,
        lng: viewStore.currentCameraPosition.longitude
      )
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: 15)
      DispatchQueue.main.async {
        uiView.mapView.moveCamera(cameraUpdate) { _ in
          viewStore.send(.movedToCurrentPosition)
        }
      }
    }

    if NaverMapView.storage.cafes != viewStore.state.cafeMarkerList {
      NaverMapView.storage.cafes = viewStore.state.cafeMarkerList
      DispatchQueue.main.async {
        addMarker(naverMapView: uiView, cafeList: viewStore.cafeMarkerList, coordinator: context.coordinator)
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

  func addMarker(naverMapView: NMFNaverMapView, cafeList: [Cafe], coordinator: Coordinator) {
    removeAllMarkers()
    for cafe in cafeList {
      let marker = MapMarker(
        cafe: cafe,
        position: NMGLatLng(lat: cafe.latitude, lng: cafe.longitude),
        iconImage: NMFOverlayImage(image: NaverMapView.storage.unselectedIconImage)
      )

      marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
        NaverMapView.storage.selectedMarker = marker

        DispatchQueue.main.async {
          viewStore.send(.markerTapped(cafe: cafe))
        }

        moveCameraTo(naverMapView: naverMapView,
                     location: .init(latitude: cafe.latitude, longitude: cafe.longitude),
                     zoomLevel: 18)
        return true
      }
      marker.mapView = naverMapView.mapView
      NaverMapView.storage.markers.append(marker)
    }
  }

  func moveCameraTo(naverMapView: NMFNaverMapView, location: CLLocationCoordinate2D, zoomLevel: Double) {
    let nmgLocation = NMGLatLng(lat: location.latitude, lng: location.longitude)
    let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: zoomLevel)
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

extension Coordinator: NMFMapViewTouchDelegate {
  func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
    if let marker = NaverMapView.storage.selectedMarker {
      marker.width = 24
      marker.height = 24
      marker.iconImage = NMFOverlayImage(image: NaverMapView.storage.unselectedIconImage)
    }
    NaverMapView.storage.selectedMarker = nil
    DispatchQueue.main.async { [weak self] in
      self?.target.viewStore.send(.mapViewTapped)
    }
  }
}

final class MapMarker: NMFMarker {
  let cafe: Cafe

  init(
    cafe: Cafe,
    position: NMGLatLng,
    iconImage: NMFOverlayImage,
    width: CGFloat = 24,
    height: CGFloat = 24
  ) {
    self.cafe = cafe
    super.init()
    self.position = position
    self.iconImage = iconImage
    self.width = width
    self.height = height
  }
}
