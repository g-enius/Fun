//
//  FeaturedItem.swift
//  Model
//
//  Data model for featured technology items in the carousel
//

import Foundation

public struct FeaturedItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let iconName: String
    public let iconColor: ItemColor
    public let category: String
    public let timeLabel: String

    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        iconName: String,
        iconColor: ItemColor,
        category: String = "General",
        timeLabel: String = "2 sec."
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.iconColor = iconColor
        self.category = category
        self.timeLabel = timeLabel
    }

    /// Convenience initializer with just color (uses color as iconColor and default icon)
    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        color: ItemColor
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = "star.fill"
        self.iconColor = color
        self.category = "General"
        self.timeLabel = "2 sec."
    }
}

public extension FeaturedItem {
    // Carousel Set 1: Concurrency & Reactive
    static let asyncAwait = FeaturedItem(
        id: TechnologyItem.asyncAwait.rawValue,
        title: "Async/Await",
        subtitle: "Modern concurrency",
        iconName: "bolt.fill",
        iconColor: .green,
        category: "Concurrency"
    )

    static let combine = FeaturedItem(
        id: TechnologyItem.combine.rawValue,
        title: "Combine",
        subtitle: "Reactive programming",
        iconName: "arrow.triangle.merge",
        iconColor: .orange,
        category: "Reactive"
    )

    // Carousel Set 2: UI & Navigation
    static let swiftUI = FeaturedItem(
        id: TechnologyItem.swiftUI.rawValue,
        title: "SwiftUI",
        subtitle: "Pure SwiftUI + NavigationStack",
        iconName: "swift",
        iconColor: .blue,
        category: "UI Framework"
    )

    static let coordinator = FeaturedItem(
        id: TechnologyItem.coordinator.rawValue,
        title: "Coordinator",
        subtitle: "Single ObservableObject",
        iconName: "arrow.triangle.branch",
        iconColor: .purple,
        category: "Navigation"
    )

    // Carousel Set 3: Architecture
    static let mvvm = FeaturedItem(
        id: TechnologyItem.mvvm.rawValue,
        title: "MVVM",
        subtitle: "Architecture pattern",
        iconName: "square.stack.3d.up",
        iconColor: .indigo,
        category: "Architecture"
    )

    static let spmModules = FeaturedItem(
        id: TechnologyItem.spm.rawValue,
        title: "SPM Modules",
        subtitle: "6 Swift packages",
        iconName: "shippingbox.fill",
        iconColor: .brown,
        category: "Modularization"
    )

    // Carousel Set 4: Dependency Injection & Design
    static let serviceLocator = FeaturedItem(
        id: TechnologyItem.serviceLocator.rawValue,
        title: "ServiceLocator",
        subtitle: "@Service wrapper",
        iconName: "cylinder.split.1x2.fill",
        iconColor: .teal,
        category: "Dependency Injection"
    )

    static let protocolOriented = FeaturedItem(
        id: TechnologyItem.protocolOriented.rawValue,
        title: "Protocol-Oriented",
        subtitle: "Interface-based design",
        iconName: "doc.plaintext",
        iconColor: .mint,
        category: "Design Pattern"
    )

    // Carousel Set 5: Configuration & Logging
    static let featureToggles = FeaturedItem(
        id: TechnologyItem.featureToggles.rawValue,
        title: "Feature Toggles",
        subtitle: "Runtime flags",
        iconName: "switch.2",
        iconColor: .cyan,
        category: "Configuration"
    )

    static let osLog = FeaturedItem(
        id: TechnologyItem.osLog.rawValue,
        title: "OSLog",
        subtitle: "Structured logging",
        iconName: "doc.text.magnifyingglass",
        iconColor: .gray,
        category: "Logging"
    )

    // Carousel Set 6: Modern Swift
    static let swift6 = FeaturedItem(
        id: TechnologyItem.swift6.rawValue,
        title: "Swift 6",
        subtitle: "Strict concurrency",
        iconName: "swift",
        iconColor: .red,
        category: "Language"
    )

    static let swiftTesting = FeaturedItem(
        id: TechnologyItem.swiftTesting.rawValue,
        title: "Swift Testing",
        subtitle: "Modern test framework",
        iconName: "checkmark.seal.fill",
        iconColor: .green,
        category: "Testing"
    )

    // Carousel Set 7: Testing & Accessibility
    static let snapshotTesting = FeaturedItem(
        id: TechnologyItem.snapshotTesting.rawValue,
        title: "Snapshot Testing",
        subtitle: "Visual regression",
        iconName: "camera.viewfinder",
        iconColor: .pink,
        category: "Testing"
    )

    static let accessibility = FeaturedItem(
        id: TechnologyItem.accessibility.rawValue,
        title: "Accessibility",
        subtitle: "VoiceOver support",
        iconName: "accessibility",
        iconColor: .blue,
        category: "A11y"
    )

    // Carousel Set 8: Deployment & Concurrency
    static let concurrencyPatterns = FeaturedItem(
        id: TechnologyItem.concurrencyPatterns.rawValue,
        title: "Concurrency Patterns",
        subtitle: "Callbacks vs Combine vs async/await",
        iconName: "arrow.triangle.2.circlepath",
        iconColor: .orange,
        category: "Concurrency"
    )

    static let deploymentTarget = FeaturedItem(
        id: TechnologyItem.deploymentTarget.rawValue,
        title: "iOS 16+",
        subtitle: "Minimum deployment target",
        iconName: "iphone.gen3",
        iconColor: .yellow,
        category: "Platform"
    )

    // Carousel sets (2 items per page)
    private static let carouselSet1: [FeaturedItem] = [.asyncAwait, .combine]
    private static let carouselSet2: [FeaturedItem] = [.swiftUI, .coordinator]
    private static let carouselSet3: [FeaturedItem] = [.mvvm, .spmModules]
    private static let carouselSet4: [FeaturedItem] = [.serviceLocator, .protocolOriented]
    private static let carouselSet5: [FeaturedItem] = [.featureToggles, .osLog]
    private static let carouselSet6: [FeaturedItem] = [.swift6, .swiftTesting]
    private static let carouselSet7: [FeaturedItem] = [.snapshotTesting, .accessibility]
    private static let carouselSet8: [FeaturedItem] = [.deploymentTarget, .concurrencyPatterns]

    static let allCarouselSets: [[FeaturedItem]] = [
        carouselSet1, carouselSet2, carouselSet3, carouselSet4,
        carouselSet5, carouselSet6, carouselSet7, carouselSet8
    ]

    /// All featured items (flattened from carousel sets)
    static let all: [FeaturedItem] = allCarouselSets.flatMap { $0 }
}
