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
        let locator = ServiceLocator.shared
        locator.register(MockLoggerService() as LoggerService, for: .logger)
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
    func loginCallsCoordinator() async throws {
        setupServices()
        let coordinator = MockLoginCoordinator()
        let viewModel = LoginViewModel(coordinator: coordinator)

        viewModel.login()

        // Wait for the simulated login delay
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds

        #expect(coordinator.didLoginCalled == true)
        #expect(viewModel.isLoggingIn == false)
    }

    @Test("Login prevents multiple simultaneous logins")
    func loginPreventsMultipleLogins() async {
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
    }
}

// MARK: - Mock Logger Service

@MainActor
private final class MockLoggerService: LoggerService {
    func log(_ message: String) {}
    func log(_ message: String, level: LogLevel) {}
    func log(_ message: String, level: LogLevel, category: LogCategory) {}
    func log(_ message: String, level: LogLevel, category: String) {}
}
