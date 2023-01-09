// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mindera-people",
    platforms: [
      .iOS(.v16)
    ],
    products: [
        .library(name: "RootCore", targets: ["RootCore"]),
        .library(name: "RootView", targets: ["RootView"]),
        .library(name: "OnboardingCore", targets: ["OnboardingCore"]),
        .library(name: "OnboardingView", targets: ["OnboardingView"]),
        .library(name: "LoginCore", targets: ["LoginCore"]),
        .library(name: "LoginView", targets: ["LoginView"]),
        .library(name: "HomeCore", targets: ["HomeCore"]),
        .library(name: "HomeView", targets: ["HomeView"]),
        .library(name: "LoaderView", targets: ["LoaderView"]),
        .library(name: "WebView", targets: ["WebView"]),
        .library(name: "MinderaPeopleService", targets: ["MinderaPeopleService"]),
        .library(name: "KeychainService", targets: ["KeychainService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.45.0"),
        .package(url: "https://github.com/Mindera/MinderaDesignSystem-iOS", from: "0.0.2")
    ],
    targets: [
        .target(
          name: "RootCore",
          dependencies: [
            "OnboardingCore",
            "LoginCore",
            "HomeCore",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          ]
        ),
        .target(
          name: "RootView",
          dependencies: [
            "RootCore",
            "OnboardingView",
            "LoginView",
            "HomeView",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          ]
        ),
        .target(
          name: "OnboardingCore",
          dependencies: [
            "MinderaPeopleService",
            "KeychainService",
          ]
        ),
        .target(
          name: "OnboardingView",
          dependencies: [
            "OnboardingCore",
          ]
        ),
        .target(
          name: "LoginCore",
          dependencies: [
            "MinderaPeopleService",
            "KeychainService",
          ]
        ),
        .target(
          name: "LoginView",
          dependencies: [
            "LoginCore",
            "LoaderView",
            "WebView",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          ]
        ),
        .target(
          name: "HomeCore",
          dependencies: [
            "KeychainService",
          ]
        ),
        .target(
          name: "HomeView",
          dependencies: [
            "HomeCore",
          ]
        ),
        .target(
          name: "LoaderView",
          dependencies: [
            .product(name: "MinderaDesignSystem", package: "minderadesignsystem-ios")
          ]
        ),
        .target(
          name: "WebView",
          dependencies: []
        ),
        .target(
          name: "MinderaPeopleService",
          dependencies: [
            .product(name: "Dependencies", package: "swift-composable-architecture"),
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          ]
        ),
        .testTarget(
          name: "MinderaPeopleServiceTests",
          dependencies: ["MinderaPeopleService"],
          resources: [.process("JSON")]
        ),
        .target(
          name: "KeychainService",
          dependencies: [
            .product(name: "Dependencies", package: "swift-composable-architecture"),
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          ]
        ),
    ]
)
