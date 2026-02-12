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

@Suite("Session-Scoped DI Tests", .serialized)
@MainActor
struct SessionTests {

    private func resetLocator() {
        ServiceLocator.shared.reset()
    }

    // MARK: - LoginSession

    @Suite("LoginSession", .serialized)
    @MainActor
    struct LoginSessionTests {

        private func resetLocator() {
            ServiceLocator.shared.reset()
        }

        @Test("Registers core services and feature toggles")
        func registersCoreServices() {
            resetLocator()
            let session = LoginSession()
            session.activate()

            #expect(ServiceLocator.shared.isRegistered(for: .logger))
            #expect(ServiceLocator.shared.isRegistered(for: .network))
            #expect(ServiceLocator.shared.isRegistered(for: .featureToggles))
            #expect(!ServiceLocator.shared.isRegistered(for: .favorites))
            #expect(!ServiceLocator.shared.isRegistered(for: .toast))

            session.teardown()
        }

        @Test("Teardown clears all services")
        func teardownClearsServices() {
            resetLocator()
            let session = LoginSession()
            session.activate()

            #expect(ServiceLocator.shared.isRegistered(for: .logger))

            session.teardown()

            #expect(!ServiceLocator.shared.isRegistered(for: .logger))
            #expect(!ServiceLocator.shared.isRegistered(for: .network))
            #expect(!ServiceLocator.shared.isRegistered(for: .featureToggles))
        }
    }

    // MARK: - AuthenticatedSession

    @Suite("AuthenticatedSession", .serialized)
    @MainActor
    struct AuthenticatedSessionTests {

        private func resetLocator() {
            ServiceLocator.shared.reset()
        }

        @Test("Registers all five services")
        func registersAllServices() {
            resetLocator()
            let session = AuthenticatedSession()
            session.activate()

            #expect(ServiceLocator.shared.isRegistered(for: .logger))
            #expect(ServiceLocator.shared.isRegistered(for: .network))
            #expect(ServiceLocator.shared.isRegistered(for: .favorites))
            #expect(ServiceLocator.shared.isRegistered(for: .toast))
            #expect(ServiceLocator.shared.isRegistered(for: .featureToggles))

            session.teardown()
        }

        @Test("Teardown clears all services")
        func teardownClearsServices() {
            resetLocator()
            let session = AuthenticatedSession()
            session.activate()

            #expect(ServiceLocator.shared.isRegistered(for: .favorites))

            session.teardown()

            #expect(!ServiceLocator.shared.isRegistered(for: .logger))
            #expect(!ServiceLocator.shared.isRegistered(for: .network))
            #expect(!ServiceLocator.shared.isRegistered(for: .favorites))
            #expect(!ServiceLocator.shared.isRegistered(for: .toast))
            #expect(!ServiceLocator.shared.isRegistered(for: .featureToggles))
        }
    }

    // MARK: - Session Transitions

    @Suite("Session Transitions", .serialized)
    @MainActor
    struct SessionTransitionTests {

        private func resetLocator() {
            ServiceLocator.shared.reset()
        }

        @Test("Login to main: authenticated services become available")
        func loginToMainTransition() {
            resetLocator()

            // Start with login session
            let login = LoginSession()
            login.activate()
            #expect(!ServiceLocator.shared.isRegistered(for: .favorites))

            // Transition to main
            login.teardown()
            let main = AuthenticatedSession()
            main.activate()

            #expect(ServiceLocator.shared.isRegistered(for: .favorites))
            #expect(ServiceLocator.shared.isRegistered(for: .toast))
            #expect(ServiceLocator.shared.isRegistered(for: .featureToggles))

            main.teardown()
        }

        @Test("Main to login: authenticated services removed")
        func mainToLoginTransition() {
            resetLocator()

            // Start with main session
            let main = AuthenticatedSession()
            main.activate()
            #expect(ServiceLocator.shared.isRegistered(for: .favorites))

            // Transition to login
            main.teardown()
            let login = LoginSession()
            login.activate()

            #expect(ServiceLocator.shared.isRegistered(for: .logger))
            #expect(ServiceLocator.shared.isRegistered(for: .network))
            #expect(ServiceLocator.shared.isRegistered(for: .featureToggles))
            #expect(!ServiceLocator.shared.isRegistered(for: .favorites))
            #expect(!ServiceLocator.shared.isRegistered(for: .toast))

            login.teardown()
        }

        @Test("Full round-trip: login -> main -> login yields clean state")
        func fullRoundTrip() {
            resetLocator()

            // Login
            let login1 = LoginSession()
            login1.activate()

            // -> Main
            login1.teardown()
            let main = AuthenticatedSession()
            main.activate()
            #expect(ServiceLocator.shared.isRegistered(for: .favorites))

            // -> Login again
            main.teardown()
            let login2 = LoginSession()
            login2.activate()

            // Should be a clean login state
            #expect(ServiceLocator.shared.isRegistered(for: .logger))
            #expect(ServiceLocator.shared.isRegistered(for: .network))
            #expect(ServiceLocator.shared.isRegistered(for: .featureToggles))
            #expect(!ServiceLocator.shared.isRegistered(for: .favorites))
            #expect(!ServiceLocator.shared.isRegistered(for: .toast))

            login2.teardown()
        }

        @Test("Favorites are fresh after session transition")
        func favoritesDoNotPersistAcrossSessions() {
            resetLocator()
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.favorites)

            // First authenticated session: add a favorite
            let main1 = AuthenticatedSession()
            main1.activate()

            let favorites1: FavoritesServiceProtocol = ServiceLocator.shared.resolve(for: .favorites)
            favorites1.addFavorite("test-item")
            #expect(favorites1.isFavorited("test-item"))

            // Tear down — this should clear UserDefaults favorites
            main1.teardown()

            // New session — favorites should be default, not carrying "test-item"
            let main2 = AuthenticatedSession()
            main2.activate()

            let favorites2: FavoritesServiceProtocol = ServiceLocator.shared.resolve(for: .favorites)
            #expect(!favorites2.isFavorited("test-item"))

            main2.teardown()
        }
    }
}
