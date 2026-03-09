//
//  ProfileViewModelTests.swift
//  ViewModel
//
//  Unit tests for ProfileViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

extension ViewModelTestSuite {

@Suite("ProfileViewModel Tests")
@MainActor
struct ProfileViewModelTests {

    // MARK: - Setup

    private func makeServiceLocator() -> ServiceLocator {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        return locator
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches demo profile")
    func testInitialState() async {
        let viewModel = ProfileViewModel(serviceLocator: makeServiceLocator())

        #expect(viewModel.userName == UserProfile.demo.name)
        #expect(viewModel.userEmail == UserProfile.demo.email)
        #expect(viewModel.userBio == UserProfile.demo.bio)
        #expect(viewModel.viewCount == UserProfile.demo.viewsCount)
        #expect(viewModel.favoritesCount == UserProfile.demo.favoritesCount)
        #expect(viewModel.daysCount == UserProfile.demo.daysCount)
    }

    @Test("Custom profile values are used")
    func testCustomProfileValues() async {
        let profile = UserProfile(name: "Test", email: "test@test.com", bio: "Bio", viewsCount: 1, favoritesCount: 2, daysCount: 3)
        let viewModel = ProfileViewModel(profile: profile, serviceLocator: makeServiceLocator())

        #expect(viewModel.userName == "Test")
        #expect(viewModel.userEmail == "test@test.com")
        #expect(viewModel.viewCount == 1)
    }

    // MARK: - Dismiss Tests

    @Test("Dismiss calls onDismiss")
    func testDismissCallsOnDismiss() async {
        let viewModel = ProfileViewModel(serviceLocator: makeServiceLocator())

        var dismissCalled = false
        viewModel.onDismiss = { dismissCalled = true }

        viewModel.didTapDismiss()

        #expect(dismissCalled == true)
    }

    // MARK: - Logout Tests

    @Test("Logout calls onLogout")
    func testLogoutCallsOnLogout() async {
        let viewModel = ProfileViewModel(serviceLocator: makeServiceLocator())

        var logoutCalled = false
        viewModel.onLogout = { logoutCalled = true }

        viewModel.logout()

        #expect(logoutCalled == true)
    }

    // MARK: - Go to Items Tests

    @Test("didTapGoToItems calls onGoToItems")
    func testDidTapGoToItemsCallsOnGoToItems() async {
        let viewModel = ProfileViewModel(serviceLocator: makeServiceLocator())

        var goToItemsCalled = false
        viewModel.onGoToItems = { goToItemsCalled = true }

        viewModel.didTapGoToItems()

        #expect(goToItemsCalled == true)
    }
}
}
