//
//  Dependencies.swift
//  22nd-iOS-Team-1-iOSManifests
//
//  Created by 천수현 on 2023/05/21.
//

import ProjectDescription

let dependencies = Dependencies(
  carthage: [],
  swiftPackageManager: [
    .remote(url: "https://github.com/johnpatrickmorgan/TCACoordinators.git", requirement: .upToNextMajor(from: "0.3.0")),
    .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .upToNextMajor(from: "0.9.0")),
    .remote(url: "https://github.com/jaemyeong/NMapsMap-SPM.git", requirement: .upToNextMajor(from: "3.16.2"))
  ],
  platforms: [.iOS]
)
