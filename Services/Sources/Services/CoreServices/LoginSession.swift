//
//  LoginSession.swift
//  Services
//
//  Session for the login flow - registers core + appearance services
//

import FunCore

@MainActor
public final class LoginSession: Session {

    public let serviceLocator = ServiceLocator()

    public init() {}

    public func activate() {
        serviceLocator.register(DefaultLoggerService(), for: .logger)
        serviceLocator.register(NetworkServiceImpl(), for: .network)
        serviceLocator.register(DefaultFeatureToggleService(), for: .featureToggles)
        serviceLocator.register(DefaultToastService(), for: .toast)
    }

    public func teardown() {
        // Don't call serviceLocator.reset() — with @Service property wrapper,
        // live views may still resolve services during SwiftUI teardown.
        // The next session creates its own ServiceLocator with fresh instances.
    }
}
