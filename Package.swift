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
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "AviaryInsights",
      targets: ["AviaryInsights"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AviaryInsights",
      dependencies: [
        .product(
          name: "OpenAPIURLSession",
          package: "swift-openapi-urlsession",
          condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .macCatalyst])
        ),
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
      ],
      swiftSettings: [
        SwiftSetting.enableUpcomingFeature("BareSlashRegexLiterals"),
        SwiftSetting.enableUpcomingFeature("ConciseMagicFile"),
        SwiftSetting.enableUpcomingFeature("ExistentialAny"),
        SwiftSetting.enableUpcomingFeature("ForwardTrailingClosures"),
        SwiftSetting.enableUpcomingFeature("ImplicitOpenExistentials"),
        SwiftSetting.enableUpcomingFeature("DisableOutwardActorInference"),
        SwiftSetting.enableExperimentalFeature("StrictConcurrency"),
        .unsafeFlags(
          ["-Xcc", "-D_WASI_EMULATED_SIGNAL", "-Xcc", "-D_WASI_EMULATED_MMAN"],
          .when(platforms: [.wasi])
        ),
      ],
      linkerSettings: [
        .linkedLibrary("wasi-emulated-signal", .when(platforms: [.wasi])),
        .linkedLibrary("wasi-emulated-mman", .when(platforms: [.wasi])),
      ]
    ),
    .testTarget(
      name: "AviaryInsightsTests",
      dependencies: [
        "AviaryInsights",
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
      ]
    ),
  ]
)
