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
@testable import FunModelTestSupport

@Suite("ProfileViewModel Tests", .serialized)
@MainActor
struct ProfileViewModelTests {

    // MARK: - Setup

    init() {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockNetworkService(), for: .network)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches demo profile")
    func testInitialState() async {
        let viewModel = ProfileViewModel()

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
        let viewModel = ProfileViewModel(profile: profile)

        #expect(viewModel.userName == "Test")
        #expect(viewModel.userEmail == "test@test.com")
        #expect(viewModel.viewCount == 1)
    }

    // MARK: - Dismiss Tests

    @Test("Dismiss calls onDismiss closure")
    func testDismissCallsClosure() async {
        var dismissCalled = false
        let viewModel = ProfileViewModel(onDismiss: { dismissCalled = true })

        viewModel.didTapDismiss()

        #expect(dismissCalled == true)
    }

    // MARK: - Logout Tests

    @Test("Logout calls onLogout closure")
    func testLogoutCallsClosure() async {
        var logoutCalled = false
        let viewModel = ProfileViewModel(onLogout: { logoutCalled = true })

        viewModel.logout()

        #expect(logoutCalled == true)
    }

    // MARK: - Go to Items Tests

    @Test("didTapGoToItems calls onGoToItems closure")
    func testDidTapGoToItemsCallsClosure() async {
        var goToItemsCalled = false
        let viewModel = ProfileViewModel(onGoToItems: { goToItemsCalled = true })

        viewModel.didTapGoToItems()

        #expect(goToItemsCalled == true)
    }
}
