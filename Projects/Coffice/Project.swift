import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

// MARK: - Project
let iOSTargetVersion = "15.0"

let project = Project.app(
  name: "coffice",
  platform: .iOS,
  iOSTargetVersion: iOSTargetVersion,
  infoPlist: [
    "CFBundleShortVersionString": "1.0.0", // 앱의 출시 버전
    "CFBundleVersion": "3", // 앱의 빌드 버전 (테스트 플라이트 배포시 빌드 버전 up 필요)
    "CFBundleDisplayName": "coffice", // 사용자에게 보여질 앱의 이름
    "UILaunchStoryboardName": "LaunchScreen",
    "UIInterfaceOrientation": ["UIInterfaceOrientationPortrait"],
    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
    "UIUserInterfaceStyle": "Light",
    "NSLocationAlwaysAndWhenInUseUsageDescription": "카페 위치 제공을 위해 위치 정보가 필요합니다.",
    "NSLocationWhenInUseUsageDescription": "카페 위치 제공을 위해 위치 정보가 필요합니다.",
    "NMFClientId": "$(NMF_CLIENT_ID)",
    "LSApplicationQueriesSchemes": [
      "kakaokompassauth",
      "kakaolink",
      "kakao$(KAKAO_NATIVE_APP_KEY)"
    ],
    "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",
    "CFBundleURLTypes": [
      [
        "CFBundleTypeRole": "Editor",
        "CFBundleURLSchemes": ["kakao$(KAKAO_NATIVE_APP_KEY)"]
      ]
    ]
  ],
  dependencies: [
    .external(name: "ComposableArchitecture"),
    .external(name: "FirebaseAnalytics"),
    .external(name: "KakaoSDKAuth"),
    .external(name: "KakaoSDKCommon"),
    .external(name: "KakaoSDKUser"),
    .external(name: "Kingfisher"),
    .external(name: "NMapsMap"),
    .project(target: "Network", path: .relativeToRoot("Projects/Network")),
    .external(name: "PopupView"),
    .external(name: "TCACoordinators")
  ],
  settings: .settings(
    base: .init().otherLinkerFlags(["-ObjC"]), configurations: [
      .debug(name: .debug, xcconfig: .relativeToRoot("Xcconfig/Secrets.xcconfig")),
      .release(name: .release, xcconfig: .relativeToRoot("Xcconfig/Secrets.xcconfig"))
    ]
  )
)
