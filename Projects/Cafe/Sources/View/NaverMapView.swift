//
//  NaverMapView.swift
//  Cafe
//
//  Created by sehooon on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import SwiftUI
import NMapsMap


struct NaverMapView: UIViewRepresentable{

  func makeUIView(context: Context) -> NMFNaverMapView {
    let mapView = NMFNaverMapView()
    return mapView
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {

  }
}
