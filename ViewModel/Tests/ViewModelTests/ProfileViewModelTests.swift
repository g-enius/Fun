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

@Suite("ProfileViewModel Tests", .serialized)
@MainActor
struct ProfileViewModelTests {

    // MARK: - Setup

    private func setupServices() {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches demo profile")
    func testInitialState() async {
        setupServices()
        let viewModel = ProfileViewModel(coordinator: nil)

        #expect(viewModel.userName == UserProfile.demo.name)
        #expect(viewModel.userEmail == UserProfile.demo.email)
        #expect(viewModel.userBio == UserProfile.demo.bio)
        #expect(viewModel.viewCount == UserProfile.demo.viewsCount)
        #expect(viewModel.favoritesCount == UserProfile.demo.favoritesCount)
        #expect(viewModel.daysCount == UserProfile.demo.daysCount)
    }

    @Test("Custom profile values are used")
    func testCustomProfileValues() async {
        setupServices()
        let profile = UserProfile(name: "Test", email: "test@test.com", bio: "Bio", viewsCount: 1, favoritesCount: 2, daysCount: 3)
        let viewModel = ProfileViewModel(coordinator: nil, profile: profile)

        #expect(viewModel.userName == "Test")
        #expect(viewModel.userEmail == "test@test.com")
        #expect(viewModel.viewCount == 1)
    }

    // MARK: - Dismiss Tests

    @Test("Dismiss calls coordinator dismiss")
    func testDismissCallsCoordinator() async {
        setupServices()
        let coordinator = MockProfileCoordinator()
        let viewModel = ProfileViewModel(coordinator: coordinator)

        viewModel.didTapDismiss()

        #expect(coordinator.dismissCalled == true)
    }

    // MARK: - Logout Tests

    @Test("Logout calls coordinator logout")
    func testLogoutCallsCoordinator() async {
        setupServices()
        let coordinator = MockProfileCoordinator()
        let viewModel = ProfileViewModel(coordinator: coordinator)

        viewModel.logout()

        #expect(coordinator.logoutCalled == true)
    }

    // MARK: - Interactive Dismiss Tests

    @Test("Interactive dismiss calls coordinator didDismiss")
    func testInteractiveDismissCallsCoordinator() async {
        setupServices()
        let coordinator = MockProfileCoordinator()
        let viewModel = ProfileViewModel(coordinator: coordinator)

        viewModel.handleInteractiveDismiss()

        #expect(coordinator.didDismissCalled == true)
    }

    // MARK: - Search Items Tests

    @Test("didTapSearchItems calls coordinator dismiss and openURL")
    func testDidTapSearchItemsCallsCoordinator() async {
        setupServices()
        let coordinator = MockProfileCoordinator()
        let viewModel = ProfileViewModel(coordinator: coordinator)

        viewModel.didTapSearchItems()

        #expect(coordinator.dismissCalled == true)
        #expect(coordinator.openURLCalled == true)
        #expect(coordinator.lastOpenedURL?.absoluteString == "funapp://tab/items")
    }
}
