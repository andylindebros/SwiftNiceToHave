// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NiceToHave",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NiceToHave",
            targets: ["NiceToHave"]
        ),

        .plugin(name: "DesignSystemPlugin", targets: ["DesignSystemPlugin"]),

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .plugin(
            name: "DesignSystemPlugin",
            capability: .command(
                intent: .custom(
                    verb: "generate-code",
                    description: "Generates Swift source code from a JSON schema file."
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Needed to write generated Swift files."),
                ]
            ),
            path: "Plugins/DesignSystemPlugin"
        ),
        .target(
            name: "NiceToHave",
            dependencies: []
        ),
        .testTarget(
            name: "NiceToHaveTests",
            dependencies: ["NiceToHave"]
        ),
    ]
)
