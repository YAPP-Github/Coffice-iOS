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

  func resetValues() {
    markers.removeAll()
    selectedMarker = nil
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
    moveCameraTo(naverMapView: naverMapView, location: viewStore.naverMapState.currentCameraPosition, zoomLevel: 15)
    return naverMapView
  }

  func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
    if viewStore.naverMapState.isUpdatingCameraPosition {
      let nmgLocation = NMGLatLng(
        lat: viewStore.naverMapState.currentCameraPosition.latitude,
        lng: viewStore.naverMapState.currentCameraPosition.longitude
      )
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: 15)
      DispatchQueue.main.async {
        uiView.mapView.moveCamera(cameraUpdate) { _ in
          viewStore.send(.naverMapAction(.cameraMovedToUserPosition))
        }
      }
    }

    if viewStore.naverMapState.shouldClearMarkers {
      removeAllMarkers()
      NaverMapView.storage.resetValues()
      DispatchQueue.main.async { viewStore.send(.naverMapAction(.markersCleared)) }
    }

    if viewStore.naverMapState.shouldUpdateMarkers
        && viewStore.naverMapState.selectedCafe != nil
        && viewStore.naverMapState.selectedCafe != NaverMapView.storage.selectedMarker?.cafe {
      DispatchQueue.main.async {
        addMarker(
          naverMapView: uiView,
          cafeList: viewStore.naverMapState.cafes,
          selectedCafe: viewStore.naverMapState.selectedCafe,
          coordinator: context.coordinator
        )
      }
    }

    if viewStore.naverMapState.shouldUpdateMarkers {
      if viewStore.naverMapState.shouldShowBookmarkCafesOnly {
        removeMarkers { $0.cafe.isBookmarked.isFalse }
      } else {
        DispatchQueue.main.async {
          addMarker(
            naverMapView: uiView,
            cafeList: viewStore.naverMapState.cafes,
            selectedCafe: viewStore.naverMapState.selectedCafe,
            coordinator: context.coordinator
          )
        }
      }
    }

    if viewStore.naverMapState.isUpdatingBookmarkState {
      NaverMapView.storage.selectedMarker?.markerType.bookmarkType =
      viewStore.naverMapState.selectedCafe?.isBookmarked ?? false
      ? .bookmarked
      : .nonBookmarked
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(target: self)
  }
}

extension NaverMapView {
  func removeMarkers(filter: ((MapMarker) -> Bool)) {
    NaverMapView.storage.markers.filter(filter).forEach {
      $0.touchHandler = nil
      $0.mapView = nil
    }

    DispatchQueue.main.async {
      viewStore.send(.naverMapAction(.markersUpdated))
    }
  }

  func removeAllMarkers() {
    for marker in NaverMapView.storage.markers {
      marker.touchHandler = nil
      marker.mapView = nil
    }
    NaverMapView.storage.selectedMarker = nil
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
          viewStore.send(.naverMapAction(.markerTapped(cafe: cafe)))
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
      viewStore.send(.naverMapAction(.markersUpdated))
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
      self?.target.viewStore.send(.naverMapAction(.mapViewTapped))
    }
  }
}

extension Coordinator: NMFMapViewCameraDelegate {
  func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
    DispatchQueue.main.async { [weak self] in
      guard let updateReason = NaverMapCameraUpdateReason(rawValue: reason)
      else { return }
      self?.target.viewStore.send(.naverMapAction(.updateCameraUpdateReason(updateReason)))
    }
  }

  func mapViewCameraIdle(_ mapView: NMFMapView) {
    let latitude = mapView.cameraPosition.target.lat
    let longitude = mapView.cameraPosition.target.lng
    DispatchQueue.main.async { [weak self] in
      self?.target.viewStore.send(
        .naverMapAction(
          .cameraPositionMoved(
            newCameraPosition: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
          )
        )
      )
    }
  }
}

enum NaverMapCameraUpdateReason: Int {
  case changedByDeveloper = 0
  case changedByGesture = -1
  case changedByControl = -2
  case changedByLocation = -3
}
