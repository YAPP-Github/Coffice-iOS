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

  init(store: StoreOf<NaverMapCore>) {
    self.viewStore = ViewStoreOf<NaverMapCore>(store, observe: { $0 })
  }
}

final class NaverMapViewProgressChecker {
  static let shared = NaverMapViewProgressChecker()
  var isUpdatingMarkers = false

  private init() {}
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
    naverMapView.mapView.extent = NMGLatLngBounds(
      southWest: NMGLatLng(
        lat: 31.43,
        lng: 122.37
      ),
      northEast: NMGLatLng(lat: 44.35, lng: 132)
    )
    naverMapView.mapView.touchDelegate = context.coordinator
    moveCameraTo(naverMapView: naverMapView, location: viewStore.currentCameraPosition, zoomLevel: 15)
    context.coordinator.naverMap = naverMapView
    context.coordinator.clusterManager?.delegate = context.coordinator
    return naverMapView
  }

  func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
    if viewStore.isUpdatingCameraPosition {
      let nmgLocation = NMGLatLng(
        lat: viewStore.currentCameraPosition.latitude,
        lng: viewStore.currentCameraPosition.longitude
      )
      let zoomLevel = viewStore.zoomLevel ?? 15
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: zoomLevel)
      cameraUpdate.animation = .fly
      cameraUpdate.animationDuration = 0.3
      DispatchQueue.main.async {
        uiView.mapView.moveCamera(cameraUpdate) { _ in
          viewStore.send(.cameraMoved)
        }
      }
    }

    if viewStore.shouldClearMarkers {
      DispatchQueue.main.async { viewStore.send(.markersCleared) }
    }

    if viewStore.shouldUpdateMarkers && NaverMapViewProgressChecker.shared.isUpdatingMarkers.isFalse {
      NaverMapViewProgressChecker.shared.isUpdatingMarkers = true
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
    viewStore.send(.markersUpdated)

    var markers = [MapMarker]()
    for cafe in cafeList {
      guard viewStore.markers
        .contains(where: { $0.cafe.placeId == cafe.placeId })
        .isFalse
      else { continue }
      let marker = MapMarker(
        cafe: cafe,
        markerType: .init(
          bookmarkType: cafe.isBookmarked ? .bookmarked : .nonBookmarked,
          selectType: selectedCafe?.placeId == cafe.placeId ? .selected : .unselected
        ),
        position: NMGLatLng(lat: cafe.latitude, lng: cafe.longitude)
      )
      marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
        _ = withAnimation(.easeInOut) {
          viewStore.send(.markerTapped(cafe: cafe))
        }
        return true
      }
      marker.captionText = cafe.name.prefix(6) + "..."
      marker.captionColor = CofficeAsset.Colors.grayScale9.color
      marker.captionTextSize = CofficeFont.body2MediumSemiBold.size
      marker.captionMinZoom = 15.5
      marker.captionRequestedWidth = 0
      marker.mapView = naverMapView.mapView
      markers.append(marker)
    }

    DispatchQueue.main.async {
      viewStore.send(.appendMarkers(markers: markers))
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
  var clusterManager: ClusteringManager?
  var oldZoomLevel: Double = 0.0
  let clusterStartZoomLevel: Double = 14.0
  var naverMap: NMFNaverMapView? {
    didSet {
      if naverMap != nil {
        self.clusterManager = ClusteringManager(mapView: naverMap!.mapView, frame: naverMap!.frame)
      }
    }
  }
  var currMarkersTuple = [(NMFMarker, NMFInfoWindow?)]()

  init(target: NaverMapView) {
    self.target = target
  }
}

extension Coordinator: NMFMapViewTouchDelegate {
  func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
    _ = withAnimation {
      self.target.viewStore.send(.mapViewTapped)
    }
  }
}

extension Coordinator: NMFMapViewCameraDelegate {
  func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {

    let latitude = mapView.cameraPosition.target.lat
    let longitude = mapView.cameraPosition.target.lng

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if let updateReason = NaverMapCameraUpdateReason(rawValue: reason) {
        self.target.viewStore.send(
          .cameraPositionUpdated(
            toPosition: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            zoomLevel: mapView.zoomLevel,
            byReason: updateReason
          )
        )
      }
      if mapView.zoomLevel < self.clusterStartZoomLevel {
        if abs((self.oldZoomLevel) - mapView.zoomLevel) >= 0.2 {
          self.runClustering(markers: self.target.viewStore.markers)
          self.target.viewStore.markers.forEach {
            if $0.mapView != nil {
              $0.mapView = nil
            }
          }
          self.oldZoomLevel = mapView.zoomLevel
        }
      } else if mapView.zoomLevel >= self.clusterStartZoomLevel {
        self.target.viewStore.markers.forEach {
          $0.mapView = self.naverMap?.mapView
        }
        self.currMarkersTuple.forEach {
          if let markerwindow = $0.1 {
            markerwindow.close()
          }
          $0.0.mapView = nil
        }
      }
    }
  }
}

extension Coordinator: ClusteringManagerDelegate {
  func displayMarkers(markersTuple: [(NMFMarker, NMFInfoWindow?)]) {
    guard let naverMap else { return }
    for marker in self.currMarkersTuple {
      if let markerwindow = marker.1 {
        markerwindow.close()
      }
      marker.0.mapView = nil
    }

    self.currMarkersTuple = markersTuple

    for marker in self.currMarkersTuple {
      if let markerwindow = marker.1 {
        markerwindow.open(with: naverMap.mapView)
      } else {
        marker.0.mapView = naverMap.mapView
      }
    }
  }

  func runClustering(markers: [NMFMarker]) {
    guard let naverMap else { return }
    self.clusterManager?.resetQuadTreeSetting(mapView: naverMap.mapView, frame: naverMap.mapView.frame)
    self.clusterManager?.addMarkers(markers: markers)
    self.clusterManager?.runClustering(
      mapView: naverMap.mapView,
      frame: naverMap.mapView.frame,
      zoomScale: naverMap.mapView.zoomLevel
    )
  }
}

enum NaverMapCameraUpdateReason: Int {
  case changedByDeveloper = 0
  case changedByGesture = -1
  case changedByControl = -2
  case changedByLocation = -3
}
