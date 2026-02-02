//
//  ServiceLocator.swift
//  Toolbox
//
//  Central registry for dependency injection
//

import Foundation

// MARK: - Service Key

/// Enum defining all available services
public enum ServiceKey {
    case network
    case persistence
    case analytics
    case logger
    case auth
    case favorites
    case toast
    case featureToggles
}

// MARK: - Service Locator

/// Central registry for all services
@MainActor
public class ServiceLocator {

    /// Shared instance
    public static let shared = ServiceLocator()

    /// Registered services
    private var services: [String: Any] = [:]

    private init() {
        // Private to enforce singleton
    }

    /// Register a service
    public func register<T>(_ service: T, for key: ServiceKey) {
        let keyString = String(describing: key)
        services[keyString] = service
    }

    /// Resolve a service
    public func resolve<T>(for key: ServiceKey) -> T {
        let keyString = String(describing: key)
        guard let service = services[keyString] as? T else {
            fatalError(
                "Service not registered for key: \(key). Register in ServiceLocator.shared."
            )
        }
        return service
    }

    /// Resolve an optional service (doesn't crash if not found)
    public func resolveOptional<T>(for key: ServiceKey) -> T? {
        let keyString = String(describing: key)
        return services[keyString] as? T
    }

    /// Check if a service is registered
    public func isRegistered(for key: ServiceKey) -> Bool {
        let keyString = String(describing: key)
        return services[keyString] != nil
    }

    /// Unregister a service (useful for testing)
    public func unregister(for key: ServiceKey) {
        let keyString = String(describing: key)
        services.removeValue(forKey: keyString)
    }

    /// Clear all services (useful for testing)
    public func reset() {
        services.removeAll()
    }
}

// MARK: - @Service Property Wrapper

/// Property wrapper for convenient service access
///
/// Usage:
/// ```swift
/// class MyViewModel {
///     @Service(.network) var networkService
///     @Service(.logger) var logger
/// }
/// ```
@propertyWrapper
@MainActor
public struct Service<T> {

    private let key: ServiceKey

    public init(_ key: ServiceKey) {
        self.key = key
    }

    public var wrappedValue: T {
        ServiceLocator.shared.resolve(for: key)
    }
}
