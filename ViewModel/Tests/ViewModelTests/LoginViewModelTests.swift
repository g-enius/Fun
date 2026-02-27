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

extension ViewModelTestSuite {

@Suite("LoginViewModel Tests")
@MainActor
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

    @Test("Login failure does not call onLogin and shows error toast")
    func testLoginFailureDoesNotCallOnLogin() async {
        ServiceLocator.shared.register(MockNetworkService(shouldThrowError: true), for: .network)

        let viewModel = LoginViewModel()
        var loginCalled = false
        viewModel.onLogin = { loginCalled = true }

        viewModel.login()
        await Task.yield()

        #expect(loginCalled == false)
        #expect(viewModel.isLoggingIn == false)

        let toastService: MockToastService = ServiceLocator.shared.resolve(for: .toast)
        #expect(toastService.showToastCalled == true)
        #expect(toastService.lastType == .error)
    }
}
}
