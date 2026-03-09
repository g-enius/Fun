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

extension ViewModelTestSuite {

@Suite("SettingsViewModel Tests")
@MainActor
struct SettingsViewModelTests {

    // MARK: - Setup

    private func makeServiceLocator(
        appearanceMode: AppearanceMode = .system,
        featuredCarousel: Bool = true,
        simulateErrors: Bool = false
    ) -> (ServiceLocator, MockFeatureToggleService) {
        let mockFeatureToggle = MockFeatureToggleService(
            featuredCarousel: featuredCarousel,
            simulateErrors: simulateErrors,
            appearanceMode: appearanceMode
        )

        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(mockFeatureToggle, for: .featureToggles)

        return (locator, mockFeatureToggle)
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches service defaults")
    func testInitialStateMatchesServiceDefaults() async {
        let (locator, _) = makeServiceLocator()
        let viewModel = SettingsViewModel(serviceLocator: locator)

        #expect(viewModel.appearanceMode == .system)
        #expect(viewModel.featuredCarouselEnabled == true)
        #expect(viewModel.simulateErrorsEnabled == false)
        #expect(viewModel.aiSummaryEnabled == true)
    }

    // MARK: - Appearance Mode Tests

    @Test("Changing appearance mode updates service")
    func testChangingAppearanceModeUpdatesService() async {
        let (locator, mockService) = makeServiceLocator(appearanceMode: .system)
        let viewModel = SettingsViewModel(serviceLocator: locator)

        viewModel.appearanceMode = .dark

        #expect(mockService.appearanceMode == .dark)
    }

    @Test("Appearance mode changes propagate to service")
    func testAppearanceModeChangesPropagateToService() async {
        let (locator, mockService) = makeServiceLocator(appearanceMode: .dark)
        let viewModel = SettingsViewModel(serviceLocator: locator)

        viewModel.appearanceMode = .light

        #expect(mockService.appearanceMode == .light)
    }

    // MARK: - Feature Toggle Tests

    @Test("Toggling featured carousel updates service")
    func testTogglingFeaturedCarouselUpdatesService() async {
        let (locator, mockService) = makeServiceLocator(featuredCarousel: true)
        let viewModel = SettingsViewModel(serviceLocator: locator)

        viewModel.featuredCarouselEnabled = false

        #expect(mockService.featuredCarousel == false)
    }

    @Test("Toggling simulate errors updates service")
    func testTogglingSimulateErrorsUpdatesService() async {
        let (locator, mockService) = makeServiceLocator(simulateErrors: false)
        let viewModel = SettingsViewModel(serviceLocator: locator)

        viewModel.simulateErrorsEnabled = true

        #expect(mockService.simulateErrors == true)
    }

    // MARK: - Reset Tests

    @Test("Reset appearance sets to system")
    func testResetAppearanceSetsToSystem() async {
        let (locator, mockService) = makeServiceLocator(appearanceMode: .dark)
        let viewModel = SettingsViewModel(serviceLocator: locator)

        viewModel.resetAppearance()

        #expect(viewModel.appearanceMode == .system)
        #expect(mockService.appearanceMode == .system)
    }

    @Test("Reset feature toggles restores defaults")
    func testResetFeatureTogglesRestoresDefaults() async {
        let (locator, mockService) = makeServiceLocator(featuredCarousel: false, simulateErrors: true)
        mockService.aiSummary = false
        let viewModel = SettingsViewModel(serviceLocator: locator)

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
        let (locator, mockService) = makeServiceLocator()
        mockService.aiSummary = false
        let viewModel = SettingsViewModel(serviceLocator: locator)

        #expect(viewModel.aiSummaryEnabled == false)
    }

    @Test("Toggling AI Summary updates service")
    func testTogglingAISummaryUpdatesService() async {
        let (locator, mockService) = makeServiceLocator()
        let viewModel = SettingsViewModel(serviceLocator: locator)

        viewModel.aiSummaryEnabled = false

        #expect(mockService.aiSummary == false)
    }

}
}
