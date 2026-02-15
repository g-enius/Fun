//
//  ServiceLocator.swift
//  Core
//
//  Central registry for dependency injection
//

import Combine
import Foundation

// MARK: - Service Key

/// Enum defining all available services
public enum ServiceKey {
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

    /// Emits the key whenever a service is registered
    private let registrationSubject = PassthroughSubject<ServiceKey, Never>()
    public var serviceDidRegisterPublisher: AnyPublisher<ServiceKey, Never> {
        registrationSubject.eraseToAnyPublisher()
    }

    private init() {}

    /// Register a service
    public func register<T>(_ service: T, for key: ServiceKey) {
        services[key] = service
        registrationSubject.send(key)
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
