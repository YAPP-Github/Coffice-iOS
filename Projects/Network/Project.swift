import ProjectDescription
import ProjectDescriptionHelpers

private let projectName = "Network"
private let iOSTargetVersion = "16.0"

let project = Project.framework(
    name: projectName,
    product: .dynamicLibrary,
    platform: .iOS,
    iOSTargetVersion: iOSTargetVersion,
    dependencies: [
    ],
    shouldIncludeTest: true,
    shouldIncludeResources: true
)
