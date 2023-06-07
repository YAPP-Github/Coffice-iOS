//
//  Cllocai.swift
//  Cafe
//
//  Created by sehooon on 2023/06/01.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation
import CoreLocation
import Dependencies
import ComposableArchitecture

class LocationManager: NSObject, DependencyKey, CLLocationManagerDelegate {
  static var liveValue: LocationManager = .init()
  private let manager = CLLocationManager()
  private var region = CLLocationCoordinate2D()
  private var authorization: CLAuthorizationStatus
  private var isLocationReturend: CheckedContinuation<CLLocationCoordinate2D, Error>?
  private var isAuthorizationReturned: CheckedContinuation<CLAuthorizationStatus, Never>?
  override init() {
    authorization = manager.authorizationStatus
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
  }
  func requestAuthorization() {
    manager.requestWhenInUseAuthorization()
  }
  func fetchCurrentLocation() async throws -> CLLocationCoordinate2D {
      return try await withCheckedThrowingContinuation { [weak self] continuation in
        self?.isLocationReturend = continuation
        if self?.authorization == .authorizedWhenInUse || self?.authorization == .authorizedAlways {
          self?.manager.requestLocation()
        } else {
          self?.isLocationReturend?.resume(returning: CLLocationCoordinate2D(latitude: 37.5819, longitude: 127.0014))
          self?.isLocationReturend = nil
        }
      }
  }
}
extension DependencyValues {
  var locationManager: LocationManager {
    get { self[LocationManager.self] }
    set { self[LocationManager.self] = newValue }
  }
}
extension LocationManager {
  // TODO: 위치권한 거부 및 앱 설정 변경 필요한 케이스 분기 처리
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorization = manager.authorizationStatus
    // TODO: 위치 권한 설정 변경 시, Async처리 할 수 있도록 수정
    if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
      isAuthorizationReturned?.resume(returning: manager.authorizationStatus)
      isAuthorizationReturned = nil
    }
  }
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    region = locations.first?.coordinate ??  CLLocationCoordinate2D(latitude: 37.5819, longitude: 127.0017)
    isLocationReturend?.resume(returning: region)
    isLocationReturend = nil
  }
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    isLocationReturend?.resume(throwing: error)
    isLocationReturend = nil
  }
}
