//
//  AuthenticatedSession.swift
//  Services
//
//  Session for the authenticated/main flow - registers all services
//

import FunCore
import FunModel

@MainActor
public final class AuthenticatedSession: Session {

    @Service(.favorites) private var favoritesService: FavoritesServiceProtocol

    public init() {}

    public func activate() {
        let locator = ServiceLocator.shared
        locator.register(DefaultLoggerService(), for: .logger)
        locator.register(DefaultNetworkService(), for: .network)
        locator.register(DefaultFavoritesService(), for: .favorites)
        locator.register(DefaultToastService(), for: .toast)
        locator.register(DefaultFeatureToggleService(), for: .featureToggles)
        locator.register(DefaultAIService(), for: .ai)
    }

    public func teardown() {
        favoritesService.resetFavorites()
        ServiceLocator.shared.reset()
    }
}
