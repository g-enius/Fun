//
//  UserDefaultsKey.swift
//  Model
//
//  Centralized UserDefaults keys to avoid typos and ensure consistency
//

import Foundation

public enum UserDefaultsKey: String, Sendable {
    // Feature toggles
    case featureCarousel = "feature.carousel"
    case simulateErrors = "feature.simulateErrors"

    // App settings
    case darkModeEnabled = "app.darkModeEnabled"

    // User data
    case favorites = "app.favorites"
}

// MARK: - UserDefaults Extension

public extension UserDefaults {
    func bool(forKey key: UserDefaultsKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    func set(_ value: Bool, forKey key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    func object(forKey key: UserDefaultsKey) -> Any? {
        object(forKey: key.rawValue)
    }

    func removeObject(forKey key: UserDefaultsKey) {
        removeObject(forKey: key.rawValue)
    }

    func data(forKey key: UserDefaultsKey) -> Data? {
        data(forKey: key.rawValue)
    }

    func set(_ value: Data?, forKey key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }
}
