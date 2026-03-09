//
//  LoginSession.swift
//  Services
//
//  Session for the login flow - registers core + appearance services
//

import FunCore

@MainActor
public final class LoginSession: Session {

    private let serviceLocator: ServiceLocator

    public init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    public func activate() {
        serviceLocator.register(DefaultLoggerService(), for: .logger)
        serviceLocator.register(NetworkServiceImpl(), for: .network)
        serviceLocator.register(DefaultFeatureToggleService(), for: .featureToggles)
    }

    public func teardown() {
        serviceLocator.reset()
    }
}
