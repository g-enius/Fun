//
//  LoginViewModelTests.swift
//  ViewModelTests
//
//  Tests for LoginViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

@MainActor
@Suite("LoginViewModel Tests")
struct LoginViewModelTests {

    // MARK: - Setup

    private func setupServices() {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // MARK: - Initial State Tests

    @Test("Initial state has isLoggingIn false")
    func initialStateIsNotLoggingIn() async {
        setupServices()
        let viewModel = LoginViewModel(coordinator: nil)

        #expect(viewModel.isLoggingIn == false)
    }

    // MARK: - Login Tests

    @Test("Login sets isLoggingIn to true")
    func loginSetsIsLoggingIn() async {
        setupServices()
        let viewModel = LoginViewModel(coordinator: nil)

        viewModel.login()

        #expect(viewModel.isLoggingIn == true)
    }

    @Test("Login calls coordinator didLogin after delay")
    func loginCallsCoordinator() async {
        setupServices()
        let coordinator = MockLoginCoordinator()
        let viewModel = LoginViewModel(coordinator: coordinator)

        viewModel.login()

        // Wait for the simulated login delay
        await waitForCondition { coordinator.didLoginCalled }

        #expect(coordinator.didLoginCalled == true)
        #expect(viewModel.isLoggingIn == false)
    }

    @Test("Login prevents multiple simultaneous logins")
    func loginPreventsMultipleLogins() async throws {
        setupServices()
        let coordinator = MockLoginCoordinator()
        let viewModel = LoginViewModel(coordinator: coordinator)

        // Start first login
        viewModel.login()
        #expect(viewModel.isLoggingIn == true)

        // Try to start second login while first is in progress
        viewModel.login()

        // Should still only have one login in progress
        #expect(viewModel.isLoggingIn == true)

        // Wait for completion and verify coordinator called only once
        await waitForCondition { coordinator.didLoginCallCount == 1 }
        #expect(coordinator.didLoginCallCount == 1)
    }

    @Test("Login with nil coordinator completes without crash")
    func loginWithNilCoordinatorDoesNotCrash() async throws {
        setupServices()
        let viewModel = LoginViewModel(coordinator: nil)

        viewModel.login()
        #expect(viewModel.isLoggingIn == true)

        await waitForCondition { viewModel.isLoggingIn == false }
        #expect(viewModel.isLoggingIn == false)
    }
}
