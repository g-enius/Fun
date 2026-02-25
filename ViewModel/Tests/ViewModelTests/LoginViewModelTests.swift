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

    private func makeServiceLocator(shouldThrowError: Bool = false) -> ServiceLocator {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(shouldThrowError: shouldThrowError), for: .network)
        locator.register(MockFavoritesService(), for: .favorites)
        locator.register(MockFeatureToggleService(), for: .featureToggles)
        locator.register(MockToastService(), for: .toast)
        return locator
    }

    // MARK: - Initial State Tests

    @Test("Initial state has isLoggingIn false")
    func testInitialStateIsNotLoggingIn() async {
        let viewModel = LoginViewModel(serviceLocator: makeServiceLocator())

        #expect(viewModel.isLoggingIn == false)
    }

    // MARK: - Login Tests

    @Test("Login sets isLoggingIn to true")
    func testLoginSetsIsLoggingIn() async {
        let viewModel = LoginViewModel(serviceLocator: makeServiceLocator())

        viewModel.login()

        #expect(viewModel.isLoggingIn == true)
    }

    @Test("Login calls onLoginSuccess after network request")
    func testLoginCallsOnLoginSuccess() async {
        var loginSuccessCalled = false
        let viewModel = LoginViewModel(
            onLoginSuccess: { loginSuccessCalled = true },
            serviceLocator: makeServiceLocator()
        )

        viewModel.login()

        // Mock network service returns instantly, so yield to let the Task complete
        await Task.yield()

        #expect(loginSuccessCalled == true)
        #expect(viewModel.isLoggingIn == false)
    }

    @Test("Login prevents multiple simultaneous logins")
    func testLoginPreventsMultipleLogins() async {
        var loginSuccessCount = 0
        let viewModel = LoginViewModel(
            onLoginSuccess: { loginSuccessCount += 1 },
            serviceLocator: makeServiceLocator()
        )

        viewModel.login()
        #expect(viewModel.isLoggingIn == true)

        // Try to start second login while first is in progress
        viewModel.login()
        #expect(viewModel.isLoggingIn == true)

        // Yield to let the Task complete
        await Task.yield()

        #expect(loginSuccessCount == 1)
    }

    @Test("Login with no onLoginSuccess closure completes without crash")
    func testLoginWithNoClosureDoesNotCrash() async {
        let viewModel = LoginViewModel(serviceLocator: makeServiceLocator())

        viewModel.login()
        #expect(viewModel.isLoggingIn == true)

        await Task.yield()

        #expect(viewModel.isLoggingIn == false)
    }

    @Test("Login failure does not call onLoginSuccess and shows error toast")
    func testLoginFailureDoesNotCallOnLoginSuccess() async {
        let locator = makeServiceLocator(shouldThrowError: true)

        var loginSuccessCalled = false
        let viewModel = LoginViewModel(
            onLoginSuccess: { loginSuccessCalled = true },
            serviceLocator: locator
        )

        viewModel.login()
        await Task.yield()

        #expect(loginSuccessCalled == false)
        #expect(viewModel.isLoggingIn == false)

        let toastService: MockToastService = locator.resolve(for: .toast)
        #expect(toastService.showToastCalled == true)
        #expect(toastService.lastType == .error)
    }
}
}
