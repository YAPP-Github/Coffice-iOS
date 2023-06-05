import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

// MARK: - Project
let iOSTargetVersion = "15.0"

let project = Project.app(
  name: "Cafe",
  platform: .iOS,
  iOSTargetVersion: iOSTargetVersion,
  infoPlist: [
    "CFBundleShortVersionString": "1.0.0", // 앱의 출시 버전
    "CFBundleVersion": "1",
    "CFBundleDisplayName": "Cafe",
    "UILaunchStoryboardName": "LaunchScreen",
    "UIInterfaceOrientation": ["UIInterfaceOrientationPortrait"],
    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
    "UIUserInterfaceStyle": "Light"
  ],
  dependencies: [
    .external(name: "TCACoordinators"),
    .external(name: "ComposableArchitecture"),
    .external(name: "NMapsMap"),
    .external(name: "FirebaseAnalytics"),
    .project(target: "Network", path: .relativeToRoot("Projects/Network"))
  ]
)
