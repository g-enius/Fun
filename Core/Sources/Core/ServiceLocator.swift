//
//  ServiceLocator.swift
//  Core
//
//  Central registry for dependency injection.
//
//  Session-scoped DI: each Session creates its own ServiceLocator and registers
//  services into it. On session transition, the old ServiceLocator is released
//  with the session — no stale services. ViewModels receive the session and
//  conform to SessionProvider, which auto-provides serviceLocator for @Service.
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
///
/// `@MainActor` is required because `ServiceLocator` itself is `@MainActor` —
/// any property that returns a `ServiceLocator` must also be isolated to the main actor.
@MainActor
public protocol ServiceLocatorProvider {
    var serviceLocator: ServiceLocator { get }
}

// MARK: - SessionProvider

/// Types that hold a Session reference. Provides `serviceLocator` automatically
/// from `session.serviceLocator`, so conformers only need to store `let session: Session`.
@MainActor
public protocol SessionProvider: ServiceLocatorProvider {
    var session: Session { get }
}

// MARK: - ServiceLocatorProvider

extension SessionProvider {
    public var serviceLocator: ServiceLocator { session.serviceLocator }
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
