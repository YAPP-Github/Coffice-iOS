import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

/*
                +-------------+
                |             |
                |     App     | Contains 22ndIOSTeam1IOS App target and 22ndIOSTeam1IOS unit-test target
                |             |
         +------+-------------+-------+
         |         depends on         |
         |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+

 */

// MARK: - Project

let iOSTargetVersion = "15.0"

// Creates our project using a helper function defined in ProjectDescriptionHelpers
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
        "UIUserInterfaceStyle": "Light"
    ],
    dependencies: [
        .external(name: "TCACoordinators"),
        .external(name: "ComposableArchitecture")
    ]
)
