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
  private let storage = NaverMapViewStorage()
  private let naverMapView: NMFNaverMapView = {
    let view = NMFNaverMapView()
    view.showScaleBar = false
    view.showZoomControls = false
    view.showLocationButton = false
    view.mapView.positionMode = .direction
    view.mapView.locationOverlay.hidden = false
    view.mapView.maxZoomLevel = 50
    view.mapView.minZoomLevel = 30
    return view
  }()

  init(viewStore: ViewStoreOf<CafeMapCore>) {
    self.viewStore = viewStore
  }
}

final class NaverMapViewStorage {
  var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var markers: [NMFMarker] = []
  var cafes: [CafeMarkerData] = []
}

extension NaverMapView: UIViewRepresentable {
  func makeUIView(context: Context) -> NMFNaverMapView {
    naverMapView.mapView.addCameraDelegate(delegate: context.coordinator)
    return naverMapView
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
    if storage.location != viewStore.state.region {
      let nmgLocation = NMGLatLng(lat: viewStore.state.region.latitude, lng: viewStore.state.region.longitude)
      let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLocation, zoomTo: 15)
      naverMapView.mapView.moveCamera(cameraUpdate)
    }

    if storage.cafes != viewStore.state.cafeList {
      storage.cafes = viewStore.state.cafeList
      DispatchQueue.main.async {
        addMarker(cafeList: viewStore.cafeList, coordinator: context.coordinator)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(target: self)
  }
}

extension NaverMapView {
  func removeAllMarkers() {
    storage.markers.forEach {
      $0.touchHandler = nil
      $0.mapView = nil
    }
    storage.markers.removeAll()
  }

  func addMarker(cafeList: [CafeMarkerData], coordinator: Coordinator) {
    removeAllMarkers()
    for cafe in cafeList {
      let marker = NMFMarker()
      marker.position = NMGLatLng(lat: cafe.latitude, lng: cafe.longitude)
      marker.iconImage = NMFOverlayImage(image: CofficeAsset.Asset.mapPinFill24px.image)
      marker.width = 20
      marker.height = 20
      marker.mapView = naverMapView.mapView

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

        moveCameraTo(location: .init(latitude: cafe.latitude, longitude: cafe.longitude))
        return true
      }
      storage.markers.append(marker)
    }
  }

  func moveCameraTo(location: CLLocationCoordinate2D) {
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

final class MapThemaIconView: UIView {

    private let imageView = UIImageView()
    private let backgroundView = UIView()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  func setupImage(image: UIImage?) {
        backgroundView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        backgroundView.backgroundColor = .white

        backgroundView.layer.backgroundColor = UIColor(red: 0.267, green: 0.267, blue: 0.267, alpha: 1).cgColor
        backgroundView.layer.cornerRadius = 12

        imageView.frame = CGRect(x: 7, y: 7, width: 10, height: 10)
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.white
    }

    private func setupView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        backgroundView.addSubview(imageView)
        self.addSubview(backgroundView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),

            backgroundView.widthAnchor.constraint(equalToConstant: 24),
            backgroundView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

extension UIView {
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { renderImageContext in
            self.layer.render(in: renderImageContext.cgContext)
        }
    }
}
