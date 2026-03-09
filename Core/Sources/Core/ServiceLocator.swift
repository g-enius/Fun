//
//  ServiceLocator.swift
//  Core
//
//  Central registry for dependency injection.
//
//  Instance-based DI: the app creates one ServiceLocator() at the top (SceneDelegate)
//  and threads it through coordinators, sessions, and ViewModels. No global singleton.
//

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

    /// Registered services
    private var services: [ServiceKey: Any] = [:]

    public init() {}

    /// Register a service
    public func register<T>(_ service: T, for key: ServiceKey) {
        services[key] = service
    }

    /// Resolve a service (crashes if not registered)
    public func resolve<T>(for key: ServiceKey) -> T {
        guard let service = services[key] as? T else {
            fatalError("Service not registered for key: \(key)")
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

// MARK: - ServiceLocatorProvider

/// Any type that holds a ServiceLocator instance for instance-based DI resolution.
public protocol ServiceLocatorProvider {
    var serviceLocator: ServiceLocator { get }
}

// MARK: - @Service Property Wrapper

/// Property wrapper that resolves services from the enclosing instance's ServiceLocator.
///
/// Uses `static subscript(_enclosingInstance:)` to resolve from the enclosing type's
/// `serviceLocator` property when it conforms to `ServiceLocatorProvider`.
///
/// Future: A Swift Macro could auto-generate ServiceLocatorProvider conformance +
/// the `serviceLocator` stored property, eliminating boilerplate. On @Observable classes
/// it could also auto-add @ObservationIgnored to each @Service property.
@propertyWrapper
@MainActor
public struct Service<T> {

    private let key: ServiceKey

    public init(_ key: ServiceKey) {
        self.key = key
    }

    /// Instance-based resolution: reads from the enclosing instance's serviceLocator.
    /// Takes priority over `wrappedValue` when the enclosing type conforms to ServiceLocatorProvider.
    public static subscript<EnclosingSelf: ServiceLocatorProvider>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Service<T>>
    ) -> T {
        get {
            observed.serviceLocator.resolve(for: observed[keyPath: storageKeyPath].key)
        }
        // swiftlint:disable:next unused_setter_value
        set { /* required by compiler for ReferenceWritableKeyPath, never called */ }
    }

    /// Required by @propertyWrapper — crashes if used outside a ServiceLocatorProvider type.
    public var wrappedValue: T {
        get { notImplementedError() }
        // swiftlint:disable:next unused_setter_value
        set { notImplementedError() }
    }

    private func notImplementedError() -> Never {
        fatalError("@Service must be used inside a type conforming to ServiceLocatorProvider")
    }
}
