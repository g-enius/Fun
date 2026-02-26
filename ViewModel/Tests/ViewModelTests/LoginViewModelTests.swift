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
@Suite("LoginViewModel Tests", .serialized)
struct LoginViewModelTests {

    // MARK: - Setup

    init() {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockNetworkService(), for: .network)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // MARK: - Initial State Tests

    @Test("Initial state has isLoggingIn false")
    func testInitialStateIsNotLoggingIn() async {
        let viewModel = LoginViewModel()

        #expect(viewModel.isLoggingIn == false)
    }

    // MARK: - Login Tests

    @Test("Login sets isLoggingIn to true")
    func testLoginSetsIsLoggingIn() async {
        let viewModel = LoginViewModel()

        viewModel.login()

        #expect(viewModel.isLoggingIn == true)
    }

    @Test("Login calls onLogin after network request")
    func testLoginCallsOnLogin() async {
        let viewModel = LoginViewModel()

        var loginCalled = false
        viewModel.onLogin = { loginCalled = true }

        viewModel.login()

        // Mock network service returns instantly, so yield to let the Task complete
        await Task.yield()

        #expect(loginCalled == true)
        #expect(viewModel.isLoggingIn == false)
    }

    @Test("Login prevents multiple simultaneous logins")
    func testLoginPreventsMultipleLogins() async {
        let viewModel = LoginViewModel()

        var loginCallCount = 0
        viewModel.onLogin = { loginCallCount += 1 }

        viewModel.login()
        #expect(viewModel.isLoggingIn == true)

        // Try to start second login while first is in progress
        viewModel.login()
        #expect(viewModel.isLoggingIn == true)

        // Yield to let the Task complete
        await Task.yield()

        #expect(loginCallCount == 1)
    }

    @Test("Login with nil coordinator completes without crash")
    func testLoginWithNilCoordinatorDoesNotCrash() async {
        let viewModel = LoginViewModel()

        viewModel.login()
        #expect(viewModel.isLoggingIn == true)

        await Task.yield()

        #expect(viewModel.isLoggingIn == false)
    }
}
