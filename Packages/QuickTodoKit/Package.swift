// swift-tools-version: 6.0

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny")
]

let package = Package(
    name: "QuickTodoKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "TodoDomain", targets: ["TodoDomain"]),
        .library(name: "TodoPersistence", targets: ["TodoPersistence"]),
        .library(name: "TodoReminders", targets: ["TodoReminders"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "TaskListFeature", targets: ["TaskListFeature"]),
        .library(name: "TaskEditorFeature", targets: ["TaskEditorFeature"])
    ],
    targets: [
        // MARK: - Core

        .target(
            name: "TodoDomain",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TodoPersistence",
            dependencies: ["TodoDomain"],
            resources: [.process("Resources")],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TodoReminders",
            dependencies: ["TodoDomain"],
            resources: [.process("Resources")],
            swiftSettings: swiftSettings
        ),

        // MARK: - UI

        .target(
            name: "DesignSystem",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TaskListFeature",
            dependencies: ["TodoDomain", "DesignSystem"],
            resources: [.process("Resources")],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TaskEditorFeature",
            dependencies: ["TodoDomain", "DesignSystem"],
            resources: [.process("Resources")],
            swiftSettings: swiftSettings
        ),

        // MARK: - Tests

        .target(
            name: "TodoTestSupport",
            dependencies: ["TodoDomain"],
            path: "Tests/TodoTestSupport",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "TodoDomainTests",
            dependencies: ["TodoDomain", "TodoTestSupport"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "TodoPersistenceTests",
            dependencies: ["TodoPersistence"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "TodoRemindersTests",
            dependencies: ["TodoReminders"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "TaskListFeatureTests",
            dependencies: ["TaskListFeature", "TodoTestSupport"],
            swiftSettings: swiftSettings
        )
    ]
)
