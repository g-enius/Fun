//
//  DeepLink.swift
//  Model
//
//  Deep link enum for handling funapp:// URL scheme
//

import Foundation

/// Represents deep link navigation destinations
/// URL scheme: funapp://
public enum DeepLink: Equatable, Sendable {
    case tab(TabIndex)           // funapp://tab/items
    case item(id: String)        // funapp://item/swiftui
    case profile                 // funapp://profile

    /// Initialize from URL
    /// - Parameter url: The URL to parse (must have scheme "funapp")
    public init?(url: URL) {
        guard url.scheme == "funapp" else { return nil }

        let host = url.host
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "tab":
            guard let tabName = pathComponents.first,
                  let tab = TabIndex.from(name: tabName) else { return nil }
            self = .tab(tab)
        case "item":
            guard let id = pathComponents.first else { return nil }
            self = .item(id: id)
        case "profile":
            self = .profile
        default:
            return nil
        }
    }
}
