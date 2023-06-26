//
//  LocationManager.swift
//  Cafe
//
//  Created by sehooon on 2023/06/01.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation
import CoreLocation
import Dependencies
import ComposableArchitecture

final class LocationManager: NSObject, DependencyKey {
  static let liveValue: LocationManager = .init()
  private let manager = CLLocationManager()
  private var region = CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
  private var authorizationStatus: CLAuthorizationStatus

  override init() {
    authorizationStatus = manager.authorizationStatus
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
  }

  func requestAuthorization() {
    manager.requestWhenInUseAuthorization()
  }

  func fetchCurrentLocation() -> CLLocationCoordinate2D {
    return manager.location?.coordinate ?? region
  }
}

extension DependencyValues {
  var locationManager: LocationManager {
    get { self[LocationManager.self] }
    set { self[LocationManager.self] = newValue }
  }
}

extension LocationManager: CLLocationManagerDelegate {
  // TODO: 위치권한 거부 및 앱 설정 변경 필요한 케이스 분기 처리
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    region = locations.first?.coordinate ?? CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    debugPrint(error)
  }
}
