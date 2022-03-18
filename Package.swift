// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Trying",
    platforms: [
        .macOS(.v11),
        .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "TryingMain", targets: ["TryingMain"]),
        .library(name: "Shared", targets: ["Shared"]),
        .library(name: "Questions", targets: ["Questions"]),
        .library(name: "Answers", targets: ["Answers"]),
        .library(name: "QuestionsService", targets: ["QuestionsService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.28.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TryingMain",
            dependencies: [
              "Questions", "Answers",
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
            ]),
        .testTarget(name: "TryingMainTests", dependencies: ["TryingMain"]),
        .target(
            name: "Shared",
            dependencies: [
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "Questions",
            dependencies: [
              "Shared",
              "QuestionsService",
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
            ]),
        .testTarget(name: "QuestionsTests", dependencies: ["Questions"]),
        .target(
            name: "Answers",
            dependencies: [
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
            ]),
        .testTarget(name: "AnswersTests", dependencies: ["Answers"]),
        .target(
            name: "QuestionsService",
            dependencies: [
              "Shared",
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .testTarget(name: "QuestionsServiceTests", dependencies: ["QuestionsService"]),
    ]
)
