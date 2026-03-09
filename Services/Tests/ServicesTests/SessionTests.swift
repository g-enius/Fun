//
//  SessionTests.swift
//  Services
//
//  Unit tests for session-scoped dependency injection
//

import Testing
import Foundation
@testable import FunServices
@testable import FunCore
@testable import FunModel

@Suite("Session-Scoped DI Tests")
@MainActor
struct SessionTests {

    // MARK: - LoginSession

    @Suite("LoginSession")
    @MainActor
    struct LoginSessionTests {

        @Test("Registers core services and feature toggles")
        func registersCoreServices() {
            let locator = ServiceLocator()
            let session = LoginSession(serviceLocator: locator)
            session.activate()

            #expect(locator.isRegistered(for: .logger))
            #expect(locator.isRegistered(for: .network))
            #expect(locator.isRegistered(for: .featureToggles))
            #expect(!locator.isRegistered(for: .favorites))
            #expect(locator.isRegistered(for: .toast))
        }
    }

    // MARK: - AuthenticatedSession

    @Suite("AuthenticatedSession")
    @MainActor
    struct AuthenticatedSessionTests {

        @Test("Registers all six services")
        func registersAllServices() {
            let locator = ServiceLocator()
            let session = AuthenticatedSession(serviceLocator: locator)
            session.activate()

            #expect(locator.isRegistered(for: .logger))
            #expect(locator.isRegistered(for: .network))
            #expect(locator.isRegistered(for: .favorites))
            #expect(locator.isRegistered(for: .toast))
            #expect(locator.isRegistered(for: .featureToggles))
            #expect(locator.isRegistered(for: .ai))
        }
    }

    // MARK: - Session Transitions

    @Suite("Session Transitions")
    @MainActor
    struct SessionTransitionTests {

        @Test("Login to main: authenticated services become available")
        func loginToMainTransition() {
            let locator = ServiceLocator()

            // Start with login session
            let login = LoginSession(serviceLocator: locator)
            login.activate()
            #expect(!locator.isRegistered(for: .favorites))

            // Transition to main (teardown doesn't reset — activate overwrites)
            login.teardown()
            let main = AuthenticatedSession(serviceLocator: locator)
            main.activate()

            #expect(locator.isRegistered(for: .favorites))
            #expect(locator.isRegistered(for: .toast))
            #expect(locator.isRegistered(for: .featureToggles))
        }

        @Test("Main to login: core services are overwritten with fresh instances")
        func mainToLoginTransition() {
            let locator = ServiceLocator()

            // Start with main session
            let main = AuthenticatedSession(serviceLocator: locator)
            main.activate()
            #expect(locator.isRegistered(for: .favorites))

            // Transition to login — favorites stays registered (stale but harmless)
            // until next AuthenticatedSession.activate() overwrites it
            main.teardown()
            let login = LoginSession(serviceLocator: locator)
            login.activate()

            #expect(locator.isRegistered(for: .logger))
            #expect(locator.isRegistered(for: .network))
            #expect(locator.isRegistered(for: .featureToggles))
            // favorites remains registered (not cleared) — safe for live @Service references
            #expect(locator.isRegistered(for: .favorites))
            #expect(locator.isRegistered(for: .toast))
        }

        @Test("Favorites are fresh after session transition")
        func favoritesDoNotPersistAcrossSessions() {
            let locator = ServiceLocator()
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.favorites)

            // First authenticated session: add a favorite
            let main1 = AuthenticatedSession(serviceLocator: locator)
            main1.activate()

            let favorites1: FavoritesServiceProtocol = locator.resolve(for: .favorites)
            favorites1.addFavorite("test-item")
            #expect(favorites1.isFavorited("test-item"))

            // Tear down — this clears UserDefaults favorites but keeps services registered
            main1.teardown()

            // New session — favorites should be fresh (UserDefaults cleared + new instance)
            let main2 = AuthenticatedSession(serviceLocator: locator)
            main2.activate()

            let favorites2: FavoritesServiceProtocol = locator.resolve(for: .favorites)
            #expect(!favorites2.isFavorited("test-item"))
        }
    }
}
