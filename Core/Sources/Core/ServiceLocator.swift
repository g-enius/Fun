//
//  ServiceLocator.swift
//  Core
//
//  Central registry for dependency injection
//

import Foundation

// MARK: - Service Key

/// Enum defining all available services
///
/// `Sendable` conformance is required because `ServiceKey` is used as the element type of
/// `StreamBroadcaster<ServiceKey>`, which enforces `Element: Sendable`. `AsyncStream` values
/// flow across actor/concurrency boundaries between producer and consumer, so Swift 6 strict
/// concurrency requires the element type to be `Sendable`. Combine's `PassthroughSubject` had
/// no such requirement.
public enum ServiceKey: Sendable {
    case network
    case logger
    case favorites
    case toast
    case featureToggles
    case ai
}

// MARK: - Service Locator

/// Central registry for all services
@MainActor
public class ServiceLocator {

    /// Shared instance
    public static let shared = ServiceLocator()

    /// Registered services
    private var services: [ServiceKey: Any] = [:]

    /// Broadcasts a key whenever a service is registered
    private let registrationBroadcaster = StreamBroadcaster<ServiceKey>()
    public var serviceRegistrations: AsyncStream<ServiceKey> {
        registrationBroadcaster.makeStream()
    }

    private init() {}

    /// Register a service
    public func register<T>(_ service: T, for key: ServiceKey) {
        services[key] = service
        registrationBroadcaster.yield(key)
    }

    /// Resolve a service (crashes if not registered)
    public func resolve<T>(for key: ServiceKey) -> T {
        guard let service = services[key] as? T else {
            fatalError("Service not registered for key: \(key). Register in ServiceLocator.shared.")
        }
        return service
    }

    /// Check if a service is registered
    public func isRegistered(for key: ServiceKey) -> Bool {
        services[key] != nil
    }

    /// Clear all services (useful for testing)
    public func reset() {
        services.removeAll()
    }
}

// MARK: - @Service Property Wrapper

/// Property wrapper for convenient service access
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
