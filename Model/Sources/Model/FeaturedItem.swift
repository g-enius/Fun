//
//  FeaturedItem.swift
//  Model
//
//  Data model for featured technology items in the carousel
//

import Foundation

public struct FeaturedItem: Identifiable, Equatable, Sendable {
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
        id: "asyncawait",
        title: "Async/Await",
        subtitle: "Modern concurrency",
        iconName: "bolt.fill",
        iconColor: .green,
        category: "Concurrency"
    )

    static let combine = FeaturedItem(
        id: "combine",
        title: "Combine",
        subtitle: "Reactive programming",
        iconName: "arrow.triangle.merge",
        iconColor: .orange,
        category: "Reactive"
    )

    // Carousel Set 2: UI & Navigation
    static let swiftUI = FeaturedItem(
        id: "swiftui",
        title: "SwiftUI",
        subtitle: "Declarative UI",
        iconName: "swift",
        iconColor: .blue,
        category: "UI Framework"
    )

    static let coordinator = FeaturedItem(
        id: "coordinator",
        title: "Coordinator",
        subtitle: "Navigation pattern",
        iconName: "arrow.triangle.branch",
        iconColor: .purple,
        category: "Navigation"
    )

    // Carousel Set 3: Architecture
    static let mvvm = FeaturedItem(
        id: "mvvm",
        title: "MVVM",
        subtitle: "Architecture pattern",
        iconName: "square.stack.3d.up",
        iconColor: .indigo,
        category: "Architecture"
    )

    static let spmModules = FeaturedItem(
        id: "spm",
        title: "SPM Modules",
        subtitle: "8 Swift packages",
        iconName: "shippingbox.fill",
        iconColor: .brown,
        category: "Modularization"
    )

    // Carousel Set 4: Dependency Injection & Design
    static let serviceLocator = FeaturedItem(
        id: "servicelocator",
        title: "ServiceLocator",
        subtitle: "@Service wrapper",
        iconName: "cylinder.split.1x2.fill",
        iconColor: .teal,
        category: "Dependency Injection"
    )

    static let protocolOriented = FeaturedItem(
        id: "protocol",
        title: "Protocol-Oriented",
        subtitle: "Interface-based design",
        iconName: "doc.plaintext",
        iconColor: .mint,
        category: "Design Pattern"
    )

    // Carousel Set 5: Configuration & Logging
    static let featureToggles = FeaturedItem(
        id: "featuretoggles",
        title: "Feature Toggles",
        subtitle: "Runtime flags",
        iconName: "switch.2",
        iconColor: .cyan,
        category: "Configuration"
    )

    static let osLog = FeaturedItem(
        id: "oslog",
        title: "OSLog",
        subtitle: "Structured logging",
        iconName: "doc.text.magnifyingglass",
        iconColor: .gray,
        category: "Logging"
    )

    // Carousel Set 6: Modern Swift
    static let swift6 = FeaturedItem(
        id: "swift6",
        title: "Swift 6",
        subtitle: "Strict concurrency",
        iconName: "swift",
        iconColor: .red,
        category: "Language"
    )

    static let swiftTesting = FeaturedItem(
        id: "swifttesting",
        title: "Swift Testing",
        subtitle: "Modern test framework",
        iconName: "checkmark.seal.fill",
        iconColor: .green,
        category: "Testing"
    )

    // Carousel Set 7: Testing & Accessibility
    static let snapshotTesting = FeaturedItem(
        id: "snapshot",
        title: "Snapshot Testing",
        subtitle: "Visual regression",
        iconName: "camera.viewfinder",
        iconColor: .pink,
        category: "Testing"
    )

    static let accessibility = FeaturedItem(
        id: "accessibility",
        title: "Accessibility",
        subtitle: "VoiceOver support",
        iconName: "accessibility",
        iconColor: .blue,
        category: "A11y"
    )

    // Carousel sets (2 items per page)
    static let carouselSet1: [FeaturedItem] = [.asyncAwait, .combine]
    static let carouselSet2: [FeaturedItem] = [.swiftUI, .coordinator]
    static let carouselSet3: [FeaturedItem] = [.mvvm, .spmModules]
    static let carouselSet4: [FeaturedItem] = [.serviceLocator, .protocolOriented]
    static let carouselSet5: [FeaturedItem] = [.featureToggles, .osLog]
    static let carouselSet6: [FeaturedItem] = [.swift6, .swiftTesting]
    static let carouselSet7: [FeaturedItem] = [.snapshotTesting, .accessibility]

    static let allCarouselSets: [[FeaturedItem]] = [
        carouselSet1, carouselSet2, carouselSet3, carouselSet4,
        carouselSet5, carouselSet6, carouselSet7
    ]

    /// All featured items (flattened from carousel sets)
    static let all: [FeaturedItem] = allCarouselSets.flatMap { $0 }
}
