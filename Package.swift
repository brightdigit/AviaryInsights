// swift-tools-version: 5.9

import PackageDescription

// swiftlint:disable:next explicit_top_level_acl explicit_acl
let package = Package(
  name: "AviaryInsights",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .macCatalyst(.v13),
    .tvOS(.v13),
    .visionOS(.v1),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "AviaryInsights",
      targets: ["AviaryInsights"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "AviaryInsights",
      dependencies: [
        .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
      ],
      swiftSettings: [
        SwiftSetting.enableUpcomingFeature("BareSlashRegexLiterals"),
        SwiftSetting.enableUpcomingFeature("ConciseMagicFile"),
        SwiftSetting.enableUpcomingFeature("ExistentialAny"),
        SwiftSetting.enableUpcomingFeature("ForwardTrailingClosures"),
        SwiftSetting.enableUpcomingFeature("ImplicitOpenExistentials"),
        SwiftSetting.enableUpcomingFeature("DisableOutwardActorInference"),
        SwiftSetting.enableExperimentalFeature("StrictConcurrency"),
        SwiftSetting.unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
      ]
    ),
    .testTarget(
      name: "AviaryInsightsTests",
      dependencies: [
        "AviaryInsights",
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
      ]
    )
  ]
)
