//
//  DefaultFeatureToggleService.swift
//  Services
//
//  Default implementation of FeatureToggleServiceProtocol
//

import Foundation
import FunModel

/// Notification posted when feature toggles change
public extension Notification.Name {
    static let featureTogglesDidChange = Notification.Name("featureTogglesDidChange")
}

@MainActor
public final class DefaultFeatureToggleService: FeatureToggleServiceProtocol {

    private let carouselKey = "feature.carousel"
    private let analyticsKey = "feature.analytics"
    private let debugModeKey = "feature.debugMode"

    public var featuredCarousel: Bool {
        get { UserDefaults.standard.bool(forKey: carouselKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: carouselKey)
            NotificationCenter.default.post(name: .featureTogglesDidChange, object: nil)
        }
    }

    public var featureAnalytics: Bool {
        get { UserDefaults.standard.bool(forKey: analyticsKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: analyticsKey)
            NotificationCenter.default.post(name: .featureTogglesDidChange, object: nil)
        }
    }

    public var featureDebugMode: Bool {
        get { UserDefaults.standard.bool(forKey: debugModeKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: debugModeKey)
            NotificationCenter.default.post(name: .featureTogglesDidChange, object: nil)
        }
    }

    public init() {
        // Set default values if not already set
        if UserDefaults.standard.object(forKey: carouselKey) == nil {
            UserDefaults.standard.set(true, forKey: carouselKey)
        }
    }
}
