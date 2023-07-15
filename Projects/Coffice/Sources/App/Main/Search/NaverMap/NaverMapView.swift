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
  @ObservedObject var viewStore: ViewStoreOf<NaverMapCore>

  init(viewStore: ViewStoreOf<NaverMapCore>) {
    self.viewStore = viewStore
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
    if viewStore.isUpdatingCameraPosition {
      let nmgLocation = NMGLatLng(
        lat: viewStore.currentCameraPosition.latitude,
        lng: viewStore.currentCameraPosition.longitude
      )
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: 15)
      DispatchQueue.main.async {
        uiView.mapView.moveCamera(cameraUpdate) { _ in
          viewStore.send(.cameraMovedToUserPosition)
        }
      }
    }

    if viewStore.shouldClearMarkers {
      DispatchQueue.main.async { viewStore.send(.markersCleared) }
    }

    if viewStore.shouldUpdateMarkers
        && viewStore.selectedCafe != nil {
      DispatchQueue.main.async {
        addMarker(
          naverMapView: uiView,
          cafeList: viewStore.cafes,
          selectedCafe: viewStore.selectedCafe,
          coordinator: context.coordinator
        )
      }
    }

    if viewStore.shouldUpdateMarkers {
      if viewStore.shouldShowBookmarkCafesOnly {
        DispatchQueue.main.async {
          addMarker(
            naverMapView: uiView,
            cafeList: viewStore.cafes.filter { $0.isBookmarked },
            selectedCafe: viewStore.selectedCafe,
            coordinator: context.coordinator
          )
        }
      } else {
        DispatchQueue.main.async {
          addMarker(
            naverMapView: uiView,
            cafeList: viewStore.cafes,
            selectedCafe: viewStore.selectedCafe,
            coordinator: context.coordinator
          )
        }
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(target: self)
  }
}

extension NaverMapView {
  func addMarker(naverMapView: NMFNaverMapView, cafeList: [Cafe], selectedCafe: Cafe?, coordinator: Coordinator) {
    for cafe in cafeList {
      let marker = MapMarker(
        cafe: cafe,
        markerType: .init(
          bookmarkType: cafe.isBookmarked ? .bookmarked : .nonBookmarked,
          selectType: selectedCafe?.placeId == cafe.placeId ? .selected : .unselected
        ),
        position: NMGLatLng(lat: cafe.latitude, lng: cafe.longitude)
      )
      if marker.markerType.selectType == .selected {
      }
      marker.touchHandler = { (overlay: NMFOverlay) -> Bool in

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
      viewStore.send(.appendMarker(marker: marker))
    }
    DispatchQueue.main.async {
      viewStore.send(.markersUpdated)
    }
  }

  func moveCameraTo(naverMapView: NMFNaverMapView, location: CLLocationCoordinate2D, zoomLevel: Double? = nil) {
    let nmgLocation = NMGLatLng(lat: location.latitude, lng: location.longitude)
    if let zoomLevel {
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: zoomLevel)
      cameraUpdate.animation = .easeIn
      naverMapView.mapView.moveCamera(cameraUpdate)
    } else {
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation)
      cameraUpdate.animation = .easeIn
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
    DispatchQueue.main.async { [weak self] in
      self?.target.viewStore.send(.mapViewTapped)
    }
  }
}

extension Coordinator: NMFMapViewCameraDelegate {
  func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
    DispatchQueue.main.async { [weak self] in
      guard let updateReason = NaverMapCameraUpdateReason(rawValue: reason)
      else { return }
      self?.target.viewStore.send(.updateCameraUpdateReason(updateReason))
    }
  }

  func mapViewCameraIdle(_ mapView: NMFMapView) {
    let latitude = mapView.cameraPosition.target.lat
    let longitude = mapView.cameraPosition.target.lng
    DispatchQueue.main.async { [weak self] in
      self?.target.viewStore.send(
        .cameraPositionMoved(
          newCameraPosition: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
