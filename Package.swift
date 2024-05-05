// swift-tools-version: 5.9

import PackageDescription

// swiftlint:disable:next explicit_top_level_acl explicit_acl
let package = Package(
  name: "AviaryInsights",
  products: [
    .library(
      name: "AviaryInsights",
      targets: ["AviaryInsights"]
    )
  ],
  targets: [
    .target(
      name: "AviaryInsights"
    ),
    .testTarget(
      name: "AviaryInsightsTests",
      dependencies: ["AviaryInsights"]
    )
  ]
)
