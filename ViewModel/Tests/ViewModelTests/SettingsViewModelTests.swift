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
import FunModelTestSupport

@Suite("SettingsViewModel Tests", .serialized)
@MainActor
struct SettingsViewModelTests {

    // MARK: - Setup

    private func setupServices(
        appearanceMode: AppearanceMode = .system,
        featuredCarousel: Bool = true,
        simulateErrors: Bool = false
    ) -> MockFeatureToggleService {
        let mockFeatureToggle = MockFeatureToggleService(
            featuredCarousel: featuredCarousel,
            simulateErrors: simulateErrors,
            appearanceMode: appearanceMode
        )

        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(mockFeatureToggle, for: .featureToggles)

        return mockFeatureToggle
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches service defaults")
    func testInitialStateMatchesServiceDefaults() async {
        _ = setupServices()
        let viewModel = SettingsViewModel(coordinator: nil)

        #expect(viewModel.appearanceMode == .system)
        #expect(viewModel.featuredCarouselEnabled == true)
        #expect(viewModel.simulateErrorsEnabled == false)
        #expect(viewModel.aiSummaryEnabled == true)
    }

    // MARK: - Appearance Mode Tests

    @Test("Changing appearance mode updates service")
    func testChangingAppearanceModeUpdatesService() async {
        let mockService = setupServices(appearanceMode: .system)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.appearanceMode = .dark

        #expect(mockService.appearanceMode == .dark)
    }

    @Test("Appearance mode changes propagate to service")
    func testAppearanceModeChangesPropagateToService() async {
        let mockService = setupServices(appearanceMode: .dark)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.appearanceMode = .light

        #expect(mockService.appearanceMode == .light)
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

    @Test("Reset appearance sets to system")
    func testResetAppearanceSetsToSystem() async {
        let mockService = setupServices(appearanceMode: .dark)
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.resetAppearance()

        #expect(viewModel.appearanceMode == .system)
        #expect(mockService.appearanceMode == .system)
    }

    @Test("Reset feature toggles restores defaults")
    func testResetFeatureTogglesRestoresDefaults() async {
        let mockService = setupServices(featuredCarousel: false, simulateErrors: true)
        mockService.aiSummary = false
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.resetFeatureToggles()

        #expect(viewModel.featuredCarouselEnabled == true)
        #expect(viewModel.simulateErrorsEnabled == false)
        #expect(viewModel.aiSummaryEnabled == true)
        #expect(mockService.featuredCarousel == true)
        #expect(mockService.simulateErrors == false)
        #expect(mockService.aiSummary == true)
    }

    // MARK: - AI Summary Toggle Tests

    @Test("AI Summary enabled initializes from service")
    func testAISummaryEnabledInitFromService() async {
        let mockService = setupServices()
        mockService.aiSummary = false
        let viewModel = SettingsViewModel(coordinator: nil)

        #expect(viewModel.aiSummaryEnabled == false)
    }

    @Test("Toggling AI Summary updates service")
    func testTogglingAISummaryUpdatesService() async {
        let mockService = setupServices()
        let viewModel = SettingsViewModel(coordinator: nil)

        viewModel.aiSummaryEnabled = false

        #expect(mockService.aiSummary == false)
    }

}
