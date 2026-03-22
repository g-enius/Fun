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

    private func makeSession(
        appearanceMode: AppearanceMode = .system,
        featuredCarousel: Bool = true,
        simulateErrors: Bool = false
    ) -> (MockSession, MockFeatureToggleService) {
        let mockFeatureToggle = MockFeatureToggleService(
            featuredCarousel: featuredCarousel,
            simulateErrors: simulateErrors,
            appearanceMode: appearanceMode
        )

        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(mockFeatureToggle, for: .featureToggles)

        return (MockSession(serviceLocator: locator), mockFeatureToggle)
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches service defaults")
    func testInitialStateMatchesServiceDefaults() async {
        let (session, _) = makeSession()
        let viewModel = SettingsViewModel(session: session)

        #expect(viewModel.appearanceMode == .system)
        #expect(viewModel.featuredCarouselEnabled == true)
        #expect(viewModel.simulateErrorsEnabled == false)
        #expect(viewModel.aiSummaryEnabled == true)
    }

    // MARK: - Appearance Mode Tests

    @Test("Changing appearance mode updates service")
    func testChangingAppearanceModeUpdatesService() async {
        let (session, mockService) = makeSession(appearanceMode: .system)
        let viewModel = SettingsViewModel(session: session)

        viewModel.appearanceMode = .dark

        #expect(mockService.appearanceMode == .dark)
    }

    @Test("Appearance mode changes propagate to service")
    func testAppearanceModeChangesPropagateToService() async {
        let (session, mockService) = makeSession(appearanceMode: .dark)
        let viewModel = SettingsViewModel(session: session)

        viewModel.appearanceMode = .light

        #expect(mockService.appearanceMode == .light)
    }

    // MARK: - Feature Toggle Tests

    @Test("Toggling featured carousel updates service")
    func testTogglingFeaturedCarouselUpdatesService() async {
        let (session, mockService) = makeSession(featuredCarousel: true)
        let viewModel = SettingsViewModel(session: session)

        viewModel.featuredCarouselEnabled = false

        #expect(mockService.featuredCarousel == false)
    }

    @Test("Toggling simulate errors updates service")
    func testTogglingSimulateErrorsUpdatesService() async {
        let (session, mockService) = makeSession(simulateErrors: false)
        let viewModel = SettingsViewModel(session: session)

        viewModel.simulateErrorsEnabled = true

        #expect(mockService.simulateErrors == true)
    }

    // MARK: - Reset Tests

    @Test("Reset appearance sets to system")
    func testResetAppearanceSetsToSystem() async {
        let (session, mockService) = makeSession(appearanceMode: .dark)
        let viewModel = SettingsViewModel(session: session)

        viewModel.resetAppearance()

        #expect(viewModel.appearanceMode == .system)
        #expect(mockService.appearanceMode == .system)
    }

    @Test("Reset feature toggles restores defaults")
    func testResetFeatureTogglesRestoresDefaults() async {
        let (session, mockService) = makeSession(featuredCarousel: false, simulateErrors: true)
        mockService.aiSummary = false
        let viewModel = SettingsViewModel(session: session)

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
        let (session, mockService) = makeSession()
        mockService.aiSummary = false
        let viewModel = SettingsViewModel(session: session)

        #expect(viewModel.aiSummaryEnabled == false)
    }

    @Test("Toggling AI Summary updates service")
    func testTogglingAISummaryUpdatesService() async {
        let (session, mockService) = makeSession()
        let viewModel = SettingsViewModel(session: session)

        viewModel.aiSummaryEnabled = false

        #expect(mockService.aiSummary == false)
    }

}
}
