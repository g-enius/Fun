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
            #expect(!locator.isRegistered(for: .toast))

            session.teardown()
        }

        @Test("Teardown clears all services")
        func teardownClearsServices() {
            let locator = ServiceLocator()
            let session = LoginSession(serviceLocator: locator)
            session.activate()

            #expect(locator.isRegistered(for: .logger))

            session.teardown()

            #expect(!locator.isRegistered(for: .logger))
            #expect(!locator.isRegistered(for: .network))
            #expect(!locator.isRegistered(for: .featureToggles))
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

            session.teardown()
        }

        @Test("Teardown clears all services")
        func teardownClearsServices() {
            let locator = ServiceLocator()
            let session = AuthenticatedSession(serviceLocator: locator)
            session.activate()

            #expect(locator.isRegistered(for: .favorites))

            session.teardown()

            #expect(!locator.isRegistered(for: .logger))
            #expect(!locator.isRegistered(for: .network))
            #expect(!locator.isRegistered(for: .favorites))
            #expect(!locator.isRegistered(for: .toast))
            #expect(!locator.isRegistered(for: .featureToggles))
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

            // Transition to main
            login.teardown()
            let main = AuthenticatedSession(serviceLocator: locator)
            main.activate()

            #expect(locator.isRegistered(for: .favorites))
            #expect(locator.isRegistered(for: .toast))
            #expect(locator.isRegistered(for: .featureToggles))

            main.teardown()
        }

        @Test("Main to login: authenticated services removed")
        func mainToLoginTransition() {
            let locator = ServiceLocator()

            // Start with main session
            let main = AuthenticatedSession(serviceLocator: locator)
            main.activate()
            #expect(locator.isRegistered(for: .favorites))

            // Transition to login
            main.teardown()
            let login = LoginSession(serviceLocator: locator)
            login.activate()

            #expect(locator.isRegistered(for: .logger))
            #expect(locator.isRegistered(for: .network))
            #expect(locator.isRegistered(for: .featureToggles))
            #expect(!locator.isRegistered(for: .favorites))
            #expect(!locator.isRegistered(for: .toast))

            login.teardown()
        }

        @Test("Full round-trip: login -> main -> login yields clean state")
        func fullRoundTrip() {
            let locator = ServiceLocator()

            // Login
            let login1 = LoginSession(serviceLocator: locator)
            login1.activate()

            // -> Main
            login1.teardown()
            let main = AuthenticatedSession(serviceLocator: locator)
            main.activate()
            #expect(locator.isRegistered(for: .favorites))

            // -> Login again
            main.teardown()
            let login2 = LoginSession(serviceLocator: locator)
            login2.activate()

            // Should be a clean login state
            #expect(locator.isRegistered(for: .logger))
            #expect(locator.isRegistered(for: .network))
            #expect(locator.isRegistered(for: .featureToggles))
            #expect(!locator.isRegistered(for: .favorites))
            #expect(!locator.isRegistered(for: .toast))

            login2.teardown()
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

            // Tear down — this should clear UserDefaults favorites
            main1.teardown()

            // New session — favorites should be default, not carrying "test-item"
            let main2 = AuthenticatedSession(serviceLocator: locator)
            main2.activate()

            let favorites2: FavoritesServiceProtocol = locator.resolve(for: .favorites)
            #expect(!favorites2.isFavorited("test-item"))

            main2.teardown()
        }
    }
}
