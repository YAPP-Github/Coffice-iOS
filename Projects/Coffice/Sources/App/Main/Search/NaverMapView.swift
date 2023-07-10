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
        oldValue.markerType.selectType = .unSelected
      }
      if let selectedMarker {
        selectedMarker.markerType.selectType = .selected
      }
    }
  }
  var cafes: [Cafe] = []
  let unselectedIconImage = CofficeAsset.Asset.unselected20px.image
  let selectedIconImage = CofficeAsset.Asset.selected2836px.image
  let bookmarkUnselectedIconImage = CofficeAsset.Asset.bookmarkUnselected20px.image
  let bookmarkSelectedIconImage = CofficeAsset.Asset.bookmarkSelected2836px.image

  func resetValues() {
    markers.removeAll()
    selectedMarker = nil
    cafes.removeAll()
  }
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

    if viewStore.shouldClearMarkers {
      removeAllMarkers()
      NaverMapView.storage.resetValues()
      DispatchQueue.main.async { viewStore.send(.cleardMarkers) }
    }

    if viewStore.shouldUpdateMarkers
        && NaverMapView.storage.cafes != viewStore.cafeMarkerList {
      NaverMapView.storage.cafes = viewStore.cafeMarkerList
      DispatchQueue.main.async {
        addMarker(
          naverMapView: uiView,
          cafeList: NaverMapView.storage.cafes,
          selectedCafe: viewStore.selectedCafe,
          coordinator: context.coordinator
        )
      }
    }

    if viewStore.isUpdatingBookmarkState {
      NaverMapView.storage.selectedMarker?.markerType.bookmarkType =
      viewStore.selectedCafe?.isBookmarked ?? false
      ? .bookmarked
      : .nonBookmarked
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

  func addMarker(naverMapView: NMFNaverMapView, cafeList: [Cafe], selectedCafe: Cafe?, coordinator: Coordinator) {
    removeAllMarkers()
    for cafe in cafeList {
      let marker = MapMarker(
        cafe: cafe,
        markerType: .init(
          bookmarkType: cafe.isBookmarked ? .bookmarked : .nonBookmarked,
          selectType: selectedCafe?.placeId == cafe.placeId ? .selected : .unSelected
        ),
        position: NMGLatLng(lat: cafe.latitude, lng: cafe.longitude)
      )
      if marker.markerType.selectType == .selected {
        NaverMapView.storage.selectedMarker = marker
      }
      marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
        NaverMapView.storage.selectedMarker = marker

        DispatchQueue.main.async {
          viewStore.send(.markerTapped(cafe: cafe))
        }

        return true
      }
      marker.captionText = cafe.name
      marker.captionColor = CofficeAsset.Colors.grayScale9.color
      marker.captionTextSize = CofficeFont.body2MediumSemiBold.size
      marker.captionMinZoom = 15.5
      marker.captionRequestedWidth = 90

      marker.mapView = naverMapView.mapView
      NaverMapView.storage.markers.append(marker)
    }
    DispatchQueue.main.async {
      viewStore.send(.markersUpdated)
    }
  }

  func moveCameraTo(naverMapView: NMFNaverMapView, location: CLLocationCoordinate2D, zoomLevel: Double? = nil) {
    let nmgLocation = NMGLatLng(lat: location.latitude, lng: location.longitude)

    if let zoomLevel {
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: zoomLevel)
      naverMapView.mapView.moveCamera(cameraUpdate)
    } else {
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation)
      naverMapView.mapView.moveCamera(cameraUpdate)
    }
  }
}

class Coordinator: NSObject, NMFMapViewOptionDelegate {
  var target: NaverMapView

  init(target: NaverMapView) {
    self.target = target
  }
}

extension Coordinator: NMFMapViewTouchDelegate {
  func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
    NaverMapView.storage.selectedMarker = nil
    DispatchQueue.main.async { [weak self] in
      self?.target.viewStore.send(.mapViewTapped)
    }
  }
}

extension Coordinator: NMFMapViewCameraDelegate {
  func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
    DispatchQueue.main.async { [weak self] in
      self?.target.viewStore.send(.updateCameraMovementState(.move, reason))
    }
  }

  func mapViewCameraIdle(_ mapView: NMFMapView) {
    DispatchQueue.main.async { [weak self] in
      self?.target.viewStore.send(.updateCameraMovementState(.stop, nil))
    }
  }
}
