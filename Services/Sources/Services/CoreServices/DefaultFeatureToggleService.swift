//
//  DefaultFeatureToggleService.swift
//  Services
//
//  Default implementation of FeatureToggleServiceProtocol
//

import Foundation
import FunModel

@MainActor
public final class DefaultFeatureToggleService: FeatureToggleServiceProtocol {

    public var featuredCarousel: Bool {
        get { UserDefaults.standard.bool(forKey: .featureCarousel) }
        set {
            UserDefaults.standard.set(newValue, forKey: .featureCarousel)
            NotificationCenter.default.post(name: .featureTogglesDidChange, object: nil)
        }
    }

    public var featureAnalytics: Bool {
        get { UserDefaults.standard.bool(forKey: .featureAnalytics) }
        set {
            UserDefaults.standard.set(newValue, forKey: .featureAnalytics)
            NotificationCenter.default.post(name: .featureTogglesDidChange, object: nil)
        }
    }

    public var featureDebugMode: Bool {
        get { UserDefaults.standard.bool(forKey: .featureDebugMode) }
        set {
            UserDefaults.standard.set(newValue, forKey: .featureDebugMode)
            NotificationCenter.default.post(name: .featureTogglesDidChange, object: nil)
        }
    }

    public init() {
        if UserDefaults.standard.object(forKey: .featureCarousel) == nil {
            UserDefaults.standard.set(true, forKey: .featureCarousel)
        }
    }
}
