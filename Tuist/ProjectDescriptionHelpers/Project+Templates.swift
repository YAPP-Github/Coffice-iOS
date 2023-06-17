import ProjectDescription

extension Project {
  private static let organizationName = "kr.co.yapp"

  public static func app(
    name: String,
    platform: Platform,
    iOSTargetVersion: String,
    infoPlist: [String: InfoPlist.Value],
    dependencies: [TargetDependency] = [],
    settings: Settings? = nil,
    schemes: [Scheme] = []
  ) -> Project {
      let targets = makeAppTargets(name: name,
                                   platform: platform,
                                   iOSTargetVersion: iOSTargetVersion,
                                 infoPlist: infoPlist,
                                 dependencies: dependencies,
                                 settings: settings)
    return Project(name: name,
                   organizationName: organizationName,
                   targets: targets,
                   schemes: schemes)
  }

  public static func framework(
    name: String,
    product: Product = .staticFramework,
    platform: Platform, iOSTargetVersion: String,
    dependencies: [TargetDependency] = [],
    shouldIncludeTest: Bool,
    shouldIncludeResources: Bool
  ) -> Project {
    let targets = makeFrameworkTargets(
      name: name,
      product: product,
      platform: platform,
      iOSTargetVersion: iOSTargetVersion,
      dependencies: dependencies,
      shouldIncludeTest: shouldIncludeTest,
      shouldIncludeResources: shouldIncludeResources
    )
    return Project(name: name,
                   organizationName: organizationName,
                   targets: targets)
  }
}

private extension Project {

  static func makeFrameworkTargets(
    name: String,
    product: Product = .staticFramework,
    platform: Platform = .iOS,
    iOSTargetVersion: String,
    dependencies: [TargetDependency] = [],
    shouldIncludeTest: Bool,
    shouldIncludeResources: Bool
  ) -> [Target] {
    let sources = Target(name: name,
                         platform: platform,
                         product: .staticFramework,
                         bundleId: "\(organizationName).\(name)",
                         deploymentTarget: .iOS(targetVersion: iOSTargetVersion, devices: [.iphone]),
                         infoPlist: .default,
                         sources: ["Sources/**"],
                         resources: shouldIncludeResources ? ["Resources/**"] : nil,
                         scripts: [
                          .SwiftLintString
                         ],
                         dependencies: dependencies)
    let tests = Target(name: "\(name)Tests",
                       platform: platform,
                       product: .unitTests,
                       bundleId: "\(organizationName).\(name)Tests",
                       infoPlist: .default,
                       sources: ["Tests/**"],
                       scripts: [
                         .SwiftLintString
                       ],
                       dependencies: [
                        .target(name: name)
                       ])
    return shouldIncludeTest ? [sources, tests] : [sources]
  }

  static func makeAppTargets(name: String, platform: Platform, iOSTargetVersion: String, infoPlist: [String: InfoPlist.Value] = [:], dependencies: [TargetDependency] = [], settings: Settings? = nil) -> [Target] {
    let platform: Platform = platform

    let mainTarget = Target(
      name: name,
      platform: platform,
      product: .app,
      bundleId: "\(organizationName).\(name)",
      deploymentTarget: .iOS(targetVersion: iOSTargetVersion, devices: [.iphone]),
      infoPlist: .extendingDefault(with: infoPlist),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      scripts: [
        .SwiftLintString
      ],
      dependencies: dependencies,
      settings: settings,
      launchArguments: [
        .init(name: "-FIRAnalyticsDebugEnabled", isEnabled: true)
      ]
    )

    let testTarget = Target(
      name: "\(name)Tests",
      platform: platform,
      product: .unitTests,
      bundleId: "\(organizationName).Tests",
      infoPlist: .default,
      sources: ["Tests/**"],
      scripts: [
        .SwiftLintString
      ],
      dependencies: [
        .target(name: "\(name)")
      ])
    return [mainTarget, testTarget]
  }
}

public extension TargetScript {
  static let SwiftLintString = TargetScript.pre(script: """
if test -d "/opt/homebrew/bin/"; then
    PATH="/opt/homebrew/bin/:${PATH}"
fi

export PATH

if which swiftlint > /dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
""", name: "SwiftLintString", basedOnDependencyAnalysis: false)
}
