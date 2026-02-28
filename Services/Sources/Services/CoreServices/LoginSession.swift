//
//  LoginSession.swift
//  Services
//
//  Session for the login flow - registers core + appearance services
//

import FunCore

@MainActor
public final class LoginSession: Session {

    public init() {}

    public func activate() {
        let locator = ServiceLocator.shared
        locator.register(DefaultLoggerService(), for: .logger)
        locator.register(NetworkServiceImpl(), for: .network)
        locator.register(DefaultFeatureToggleService(), for: .featureToggles)
        locator.register(DefaultToastService(), for: .toast)
    }

    public func teardown() {
        ServiceLocator.shared.reset()
    }
}
