//
//  AuthenticatedSession.swift
//  Services
//
//  Session for the authenticated/main flow - registers all services
//

import FunCore
import FunModel

@MainActor
public final class AuthenticatedSession: Session, ServiceLocatorProvider {

    public let serviceLocator: ServiceLocator
    @Service(.favorites) private var favoritesService: FavoritesServiceProtocol

    public init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    public func activate() {
        let featureToggleService = DefaultFeatureToggleService()
        serviceLocator.register(DefaultLoggerService(), for: .logger)
        serviceLocator.register(NetworkServiceImpl(shouldSimulateErrors: {
            featureToggleService.simulateErrors
        }), for: .network)
        serviceLocator.register(DefaultFavoritesService(), for: .favorites)
        serviceLocator.register(DefaultToastService(), for: .toast)
        serviceLocator.register(featureToggleService, for: .featureToggles)
        serviceLocator.register(DefaultAIService(), for: .ai)
    }

    public func teardown() {
        favoritesService.resetFavorites()
        // Don't call serviceLocator.reset() — with @Service property wrapper,
        // live views may still resolve services during SwiftUI teardown.
        // The next session's activate() overwrites with fresh instances.
    }
}
