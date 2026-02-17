//
//  HomeViewModelTests.swift
//  ViewModel
//
//  Unit tests for HomeViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

// MARK: - Test Scenarios

/// Defines feature toggle scenarios for parameterized tests
struct FeatureScenario: CustomTestStringConvertible, Sendable {
    let carousel: Bool
    let simulateErrors: Bool
    let name: String

    var testDescription: String { name }

    // Carousel visibility scenarios
    static let carouselScenarios: [FeatureScenario] = [
        .init(carousel: true, simulateErrors: false, name: "Carousel enabled"),
        .init(carousel: false, simulateErrors: false, name: "Carousel disabled"),
    ]

    // Error handling scenarios
    static let errorScenarios: [FeatureScenario] = [
        .init(carousel: true, simulateErrors: false, name: "Normal operation"),
        .init(carousel: true, simulateErrors: true, name: "Network errors"),
    ]
}

@Suite("HomeViewModel Tests", .serialized)
@MainActor
struct HomeViewModelTests {

    // MARK: - Setup

    private func setupServices(
        initialFavorites: Set<String> = [],
        featuredCarousel: Bool = true,
        simulateErrors: Bool = false
    ) {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockNetworkService(), for: .network)
        ServiceLocator.shared.register(MockFavoritesService(initialFavorites: initialFavorites), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(featuredCarousel: featuredCarousel, simulateErrors: simulateErrors), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    private func setupServices(scenario: FeatureScenario, initialFavorites: Set<String> = []) {
        setupServices(
            initialFavorites: initialFavorites,
            featuredCarousel: scenario.carousel,
            simulateErrors: scenario.simulateErrors
        )
    }

    // MARK: - Initial State Tests

    @Test("Initial hasError is false on creation")
    func testInitialHasErrorOnCreation() async {
        setupServices()
        let viewModel = HomeViewModel(coordinator: nil)

        // hasError should always start false
        #expect(viewModel.hasError == false)
    }

    @Test("Initial currentCarouselIndex is 0 on creation")
    func testInitialCarouselIndexOnCreation() async {
        setupServices()
        let viewModel = HomeViewModel(coordinator: nil)

        #expect(viewModel.currentCarouselIndex == 0)
    }

    // MARK: - Data Loading Tests

    @Test("loadFeaturedItems populates data")
    func testLoadFeaturedItemsPopulatesData() async {
        setupServices()
        let viewModel = HomeViewModel(coordinator: nil)

        await viewModel.loadFeaturedItems()

        #expect(!viewModel.featuredItems.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.hasError == false)
    }

    @Test("loadFeaturedItems with simulateErrors shows toast")
    func testLoadWithSimulateErrorsShowsToast() async {
        // Setup with simulateErrors enabled
        let mockToast = MockToastService()
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockNetworkService(), for: .network)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(featuredCarousel: true, simulateErrors: true), for: .featureToggles)
        ServiceLocator.shared.register(mockToast, for: .toast)

        let viewModel = HomeViewModel(coordinator: nil)

        // Explicitly call loadFeaturedItems and wait for it
        await viewModel.loadFeaturedItems()

        // Verify the toast was called
        let resolvedToast: MockToastService = ServiceLocator.shared.resolve(for: .toast)
        #expect(resolvedToast.showToastCalled == true)
        #expect(resolvedToast.lastType == .error)
    }

    // MARK: - Coordinator Tests

    @Test("didTapFeaturedItem calls coordinator showDetail")
    func testDidTapFeaturedItemCallsCoordinator() async throws {
        setupServices()
        let mockCoordinator = MockHomeCoordinator()
        let viewModel = HomeViewModel(coordinator: mockCoordinator)

        // Wait for data to load
        await viewModel.loadFeaturedItems()

        let firstSet = try #require(viewModel.featuredItems.first)
        let item = try #require(firstSet.first)

        viewModel.didTapFeaturedItem(item)

        #expect(mockCoordinator.showDetailCalled == true)
        #expect(mockCoordinator.showDetailItem?.id == item.id)
    }

    @Test("didTapProfile calls coordinator showProfile")
    func testDidTapProfileCallsCoordinator() async {
        setupServices()
        let mockCoordinator = MockHomeCoordinator()
        let viewModel = HomeViewModel(coordinator: mockCoordinator)

        viewModel.didTapProfile()

        #expect(mockCoordinator.showProfileCalled == true)
    }

    // MARK: - Favorites Tests

    @Test("isFavorited returns false for unfavorited item")
    func testIsFavoritedReturnsFalse() async {
        setupServices(initialFavorites: [])
        let viewModel = HomeViewModel(coordinator: nil)

        #expect(viewModel.isFavorited("unfavorited_item") == false)
    }

    @Test("isFavorited returns true for favorited item")
    func testIsFavoritedReturnsTrue() async {
        setupServices(initialFavorites: ["test_item"])
        let viewModel = HomeViewModel(coordinator: nil)

        #expect(viewModel.isFavorited("test_item") == true)
    }

    @Test("toggleFavorite updates favorites")
    func testToggleFavoriteUpdates() async {
        setupServices(initialFavorites: [])
        let viewModel = HomeViewModel(coordinator: nil)

        #expect(viewModel.isFavorited("test_item") == false)

        viewModel.toggleFavorite(for: "test_item")

        // Wait for publisher to propagate
        await Task.yield()

        #expect(viewModel.isFavorited("test_item") == true)
    }

    @Test("toggleFavorite removes favorited item")
    func testToggleFavoriteRemoves() async {
        setupServices(initialFavorites: ["test_item"])
        let viewModel = HomeViewModel(coordinator: nil)

        #expect(viewModel.isFavorited("test_item") == true)

        viewModel.toggleFavorite(for: "test_item")

        // Wait for publisher to propagate
        await Task.yield()

        #expect(viewModel.isFavorited("test_item") == false)
    }

    // MARK: - Feature Toggle Tests (Parameterized)

    @Test("Carousel visibility matches feature toggle", arguments: FeatureScenario.carouselScenarios)
    func testCarouselVisibility(scenario: FeatureScenario) async {
        setupServices(scenario: scenario)
        let viewModel = HomeViewModel(coordinator: nil)

        #expect(viewModel.isCarouselEnabled == scenario.carousel)
    }

    @Test("Mock feature toggle service supports appearanceMode")
    func testMockFeatureToggleAppearanceMode() async {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockNetworkService(), for: .network)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(appearanceMode: .dark), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)

        let service: FeatureToggleServiceProtocol = ServiceLocator.shared.resolve(for: .featureToggles)
        #expect(service.appearanceMode == .dark)
    }

    @Test("Loading behavior based on error simulation", arguments: FeatureScenario.errorScenarios)
    func testLoadingBehavior(scenario: FeatureScenario) async {
        setupServices(scenario: scenario)
        let viewModel = HomeViewModel(coordinator: nil)

        await viewModel.loadFeaturedItems()

        #expect(viewModel.hasError == scenario.simulateErrors)
        #expect(viewModel.featuredItems.isEmpty == scenario.simulateErrors)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Refresh Tests

    @Test("refresh reloads featured items")
    func testRefreshReloadsItems() async {
        setupServices()
        let viewModel = HomeViewModel(coordinator: nil)

        await viewModel.refresh()

        #expect(!viewModel.featuredItems.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.hasError == false)
    }

    // MARK: - Retry Tests

    @Test("retry calls loadFeaturedItems")
    func testRetryCallsLoad() async {
        setupServices(simulateErrors: false)
        let viewModel = HomeViewModel(coordinator: nil)

        // Clear items
        viewModel.hasError = true

        // Retry
        viewModel.retry()

        await Task.yield()

        #expect(!viewModel.featuredItems.isEmpty)
        #expect(viewModel.hasError == false)
    }

}
