//
//  TabIndex.swift
//  Model
//
//  Centralized tab index constants for type-safe tab navigation
//

import Foundation

/// Tab indices for the main tab bar
public enum TabIndex: Int, CaseIterable, Sendable {
    case home = 0
    case items = 1
    case settings = 2

    /// Parse tab index from string name (for deep link support)
    /// - Parameter name: Tab name (e.g., "home", "items", "settings")
    /// - Returns: Corresponding TabIndex, or nil if not found
    public static func from(name: String) -> TabIndex? {
        switch name.lowercased() {
        case "home": return .home
        case "items", "search": return .items
        case "settings": return .settings
        default: return nil
        }
    }
}
