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
            let session = LoginSession()
            session.activate()

            #expect(session.serviceLocator.isRegistered(for: .logger))
            #expect(session.serviceLocator.isRegistered(for: .network))
            #expect(session.serviceLocator.isRegistered(for: .featureToggles))
            #expect(!session.serviceLocator.isRegistered(for: .favorites))
        }
    }

    // MARK: - AuthenticatedSession

    @Suite("AuthenticatedSession")
    @MainActor
    struct AuthenticatedSessionTests {

        @Test("Registers all six services")
        func registersAllServices() {
            let session = AuthenticatedSession()
            session.activate()

            #expect(session.serviceLocator.isRegistered(for: .logger))
            #expect(session.serviceLocator.isRegistered(for: .network))
            #expect(session.serviceLocator.isRegistered(for: .favorites))
            #expect(session.serviceLocator.isRegistered(for: .toast))
            #expect(session.serviceLocator.isRegistered(for: .featureToggles))
            #expect(session.serviceLocator.isRegistered(for: .ai))
        }
    }

    // MARK: - Session Transitions

    @Suite("Session Transitions")
    @MainActor
    struct SessionTransitionTests {

        @Test("Login to main: each session has isolated services")
        func loginToMainTransition() {
            let login = LoginSession()
            login.activate()
            #expect(!login.serviceLocator.isRegistered(for: .favorites))

            // Transition: new session gets its own ServiceLocator
            login.teardown()
            let main = AuthenticatedSession()
            main.activate()

            #expect(main.serviceLocator.isRegistered(for: .favorites))
            #expect(main.serviceLocator.isRegistered(for: .toast))
            #expect(main.serviceLocator.isRegistered(for: .featureToggles))

            // Old session's locator is unaffected
            #expect(!login.serviceLocator.isRegistered(for: .favorites))
        }

        @Test("Main to login: no stale services from previous session")
        func mainToLoginTransition() {
            let main = AuthenticatedSession()
            main.activate()
            #expect(main.serviceLocator.isRegistered(for: .favorites))

            main.teardown()
            let login = LoginSession()
            login.activate()

            // Login session has only its own services — no stale favorites
            #expect(login.serviceLocator.isRegistered(for: .logger))
            #expect(login.serviceLocator.isRegistered(for: .network))
            #expect(login.serviceLocator.isRegistered(for: .featureToggles))
            #expect(!login.serviceLocator.isRegistered(for: .favorites))
        }

        @Test("Favorites are fresh after session transition")
        func favoritesDoNotPersistAcrossSessions() {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.favorites)

            // First authenticated session: add a favorite
            let main1 = AuthenticatedSession()
            main1.activate()

            let favorites1: FavoritesServiceProtocol = main1.serviceLocator.resolve(for: .favorites)
            favorites1.addFavorite("test-item")
            #expect(favorites1.isFavorited("test-item"))

            // Tear down — this clears UserDefaults favorites
            main1.teardown()

            // New session — favorites should be fresh (UserDefaults cleared + new instance)
            let main2 = AuthenticatedSession()
            main2.activate()

            let favorites2: FavoritesServiceProtocol = main2.serviceLocator.resolve(for: .favorites)
            #expect(!favorites2.isFavorited("test-item"))
        }
    }
}
