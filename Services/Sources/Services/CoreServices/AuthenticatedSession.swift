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

    public init() {}

    public func activate() {
        let locator = ServiceLocator.shared
        locator.register(DefaultLoggerService(), for: .logger)
        locator.register(DefaultNetworkService(), for: .network)
        locator.register(DefaultFavoritesService(), for: .favorites)
        locator.register(DefaultToastService(), for: .toast)
        locator.register(DefaultFeatureToggleService(), for: .featureToggles)
    }

    public func teardown() {
        let locator = ServiceLocator.shared
        if locator.isRegistered(for: .favorites) {
            let favorites: FavoritesServiceProtocol = locator.resolve(for: .favorites)
            favorites.resetFavorites()
        }
        locator.reset()
    }
}
