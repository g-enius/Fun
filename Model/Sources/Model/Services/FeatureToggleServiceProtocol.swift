//
//  FeatureToggleServiceProtocol.swift
//  Model
//
//  Protocol for feature toggle service
//

import Foundation
import Combine

@MainActor
public protocol FeatureToggleServiceProtocol: AnyObject {
    var featuredCarousel: Bool { get set }
    var simulateErrors: Bool { get set }
    var darkModeEnabled: Bool { get set }

    /// Publisher that emits when any feature toggle changes
    var featureTogglesDidChange: AnyPublisher<Void, Never> { get }
}

// MARK: - App Settings Publisher

/// Singleton publisher for app-wide settings changes (dark mode, etc.)
@MainActor
public final class AppSettingsPublisher {
    public static let shared = AppSettingsPublisher()

    private let subject = PassthroughSubject<Void, Never>()

    private init() {}

    /// Publisher for settings changes
    public var settingsDidChange: AnyPublisher<Void, Never> {
        subject.eraseToAnyPublisher()
    }

    /// Call when settings change
    public func notifySettingsChanged() {
        subject.send()
    }
}
