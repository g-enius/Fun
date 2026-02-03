//
//  SettingsViewModelTests.swift
//  ViewModel
//
//  Unit tests for SettingsViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore

@Suite("SettingsViewModel Tests", .serialized)
@MainActor
struct SettingsViewModelTests {

    // MARK: - Setup

    private func setupServices(
        darkModeEnabled: Bool = false,
        featuredCarousel: Bool = true,
        simulateErrors: Bool = false
    ) -> MockFeatureToggleService {
        let mockFeatureToggle = MockFeatureToggleService(
            featuredCarousel: featuredCarousel,
            simulateErrors: simulateErrors,
            darkModeEnabled: darkModeEnabled
        )

        ServiceLocator.shared.reset()
        ServiceLocator.shared.assertOnMissingService = false
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(mockFeatureToggle, for: .featureToggles)

        return mockFeatureToggle
    }

    // MARK: - Initialization Tests

    @Test("Initial dark mode state matches service")
    func testInitialDarkModeMatchesService() async {
        _ = setupServices(darkModeEnabled: true)
        let viewModel = SettingsViewModel(coordinator: nil)

        #expect(viewModel.isDarkModeEnabled == true)
    }

    @Test("Initial dark mode is false by default")
    func testInitialDarkModeFalseByDefault() async {
        _ = setupServices(darkModeEnabled: false)
        let viewModel = SettingsViewModel(coordinator: nil)

        #expect(viewModel.isDarkModeEnabled == false)
    }

    @Test("Initial featured carousel state matches service")
    func testInitialFeaturedCarouselMatchesService() async {
        _ = setupServices(featuredCarousel: false)
        let viewModel = SettingsViewModel(coordinator: nil)

        #expect(viewModel.featuredCarouselEnabled == false)
    }

    @Test("Initial simulate errors state matches service")
    func testInitialSimulateErrorsMatchesService() async {
        _ = setupServices(simulateErrors: true)
        let viewModel = SettingsViewModel(coordinator: nil)

        #expect(viewModel.simulateErrorsEnabled == true)
    }

    // MARK: - Dark Mode Toggle Tests

    @Test("Toggling dark mode updates service")
    func testTogglingDarkModeUpdatesService() async {
        let mockService = setupServices(darkModeEnabled: false)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.isDarkModeEnabled = true

        #expect(mockService.darkModeEnabled == true)
    }

    @Test("Dark mode changes propagate to service")
    func testDarkModeChangesPropagateToService() async {
        let mockService = setupServices(darkModeEnabled: true)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.isDarkModeEnabled = false

        #expect(mockService.darkModeEnabled == false)
    }

    // MARK: - Feature Toggle Tests

    @Test("Toggling featured carousel updates service")
    func testTogglingFeaturedCarouselUpdatesService() async {
        let mockService = setupServices(featuredCarousel: true)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.featuredCarouselEnabled = false

        #expect(mockService.featuredCarousel == false)
    }

    @Test("Toggling simulate errors updates service")
    func testTogglingSimulateErrorsUpdatesService() async {
        let mockService = setupServices(simulateErrors: false)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.simulateErrorsEnabled = true

        #expect(mockService.simulateErrors == true)
    }

    // MARK: - Reset Tests

    @Test("Reset dark mode sets to false")
    func testResetDarkModeSetsToFalse() async {
        let mockService = setupServices(darkModeEnabled: true)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.resetDarkMode()

        #expect(viewModel.isDarkModeEnabled == false)
        #expect(mockService.darkModeEnabled == false)
    }

    @Test("Reset feature toggles restores defaults")
    func testResetFeatureTogglesRestoresDefaults() async {
        let mockService = setupServices(featuredCarousel: false, simulateErrors: true)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.resetFeatureToggles()

        #expect(viewModel.featuredCarouselEnabled == true)
        #expect(viewModel.simulateErrorsEnabled == false)
        #expect(mockService.featuredCarousel == true)
        #expect(mockService.simulateErrors == false)
    }
}
