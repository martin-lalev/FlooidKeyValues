// swift-tools-version:6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FlooidKeyValue",
    platforms: [.iOS(.v16), .macOS(.v10_15)],
    products: [
        .library(
            name: "FlooidKeyValueStorageService",
            targets: ["FlooidKeyValueStorageService"]
        ),
        .library(
            name: "FlooidKeychainStorageClient",
            targets: ["FlooidKeychainStorageClient"]
        ),
        .library(
            name: "FlooidUserDefaultsStorageClient",
            targets: ["FlooidUserDefaultsStorageClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "509.0.0"),
    ],
    targets: [
        .target(
            name: "FlooidKeyValueStorageService",
            dependencies: [
                "FlooidKeyValueStorageMacros",
            ],
            path: "Abstract"
        ),
        .target(
            name: "FlooidKeychainStorageClient",
            dependencies: [
            	.target(name: "FlooidKeyValueStorageService"),
            ],
            path: "Keychain"
        ),
        .target(
            name: "FlooidUserDefaultsStorageClient",
            dependencies: [
            	.target(name: "FlooidKeyValueStorageService"),
            ],
            path: "UserDefaults"
        ),
        .macro(
            name: "FlooidKeyValueStorageMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Macros"
        ),
    ],
    swiftLanguageVersions: [.v6]
)
