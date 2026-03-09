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
@testable import FunModelTestSupport

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

extension ViewModelTestSuite {

@Suite("HomeViewModel Tests")
@MainActor
struct HomeViewModelTests {

    // MARK: - Setup

    private func makeServiceLocator(
        initialFavorites: Set<String> = [],
        featuredCarousel: Bool = true,
        simulateErrors: Bool = false
    ) -> ServiceLocator {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(shouldThrowError: simulateErrors), for: .network)
        locator.register(MockFavoritesService(initialFavorites: initialFavorites), for: .favorites)
        locator.register(MockFeatureToggleService(featuredCarousel: featuredCarousel, simulateErrors: simulateErrors), for: .featureToggles)
        locator.register(MockToastService(), for: .toast)
        return locator
    }

    private func makeServiceLocator(scenario: FeatureScenario, initialFavorites: Set<String> = []) -> ServiceLocator {
        makeServiceLocator(
            initialFavorites: initialFavorites,
            featuredCarousel: scenario.carousel,
            simulateErrors: scenario.simulateErrors
        )
    }

    // MARK: - Initial State Tests

    @Test("Initial hasError is false on creation")
    func testInitialHasErrorOnCreation() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())

        // hasError should always start false
        #expect(viewModel.hasError == false)
    }

    @Test("Initial currentCarouselIndex is 0 on creation")
    func testInitialCarouselIndexOnCreation() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())

        #expect(viewModel.currentCarouselIndex == 0)
    }

    // MARK: - Data Loading Tests

    @Test("loadFeaturedItems populates data")
    func testLoadFeaturedItemsPopulatesData() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())

        await viewModel.loadFeaturedItems()

        #expect(!viewModel.featuredItems.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.hasError == false)
    }

    @Test("loadFeaturedItems with network error shows toast")
    func testLoadWithNetworkErrorShowsToast() async {
        // Setup with network errors enabled
        let mockToast = MockToastService()
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(shouldThrowError: true), for: .network)
        locator.register(MockFavoritesService(), for: .favorites)
        locator.register(MockFeatureToggleService(featuredCarousel: true), for: .featureToggles)
        locator.register(mockToast, for: .toast)

        let viewModel = HomeViewModel(serviceLocator: locator)

        // Explicitly call loadFeaturedItems and wait for it
        await viewModel.loadFeaturedItems()

        // Verify the toast was called (use local ref, not ServiceLocator which may be reset by parallel tests)
        #expect(mockToast.showToastCalled == true)
        #expect(mockToast.lastType == .error)
    }

    // MARK: - Coordinator Tests

    @Test("didTapFeaturedItem calls onShowDetail closure")
    func testDidTapFeaturedItemCallsClosure() async throws {
        var showDetailItem: FeaturedItem?
        let viewModel = HomeViewModel(
            onShowDetail: { item in showDetailItem = item },
            serviceLocator: makeServiceLocator()
        )

        await viewModel.loadFeaturedItems()

        let firstSet = try #require(viewModel.featuredItems.first)
        let item = try #require(firstSet.first)

        viewModel.didTapFeaturedItem(item)

        #expect(showDetailItem?.id == item.id)
    }

    @Test("didTapProfile calls onShowProfile closure")
    func testDidTapProfileCallsClosure() async {
        var showProfileCalled = false
        let viewModel = HomeViewModel(
            onShowProfile: { showProfileCalled = true },
            serviceLocator: makeServiceLocator()
        )

        viewModel.didTapProfile()

        #expect(showProfileCalled == true)
    }

    // MARK: - Favorites Tests

    @Test("isFavorited returns false for unfavorited item")
    func testIsFavoritedReturnsFalse() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator(initialFavorites: []))

        #expect(viewModel.isFavorited("unfavorited_item") == false)
    }

    @Test("isFavorited returns true for favorited item")
    func testIsFavoritedReturnsTrue() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator(initialFavorites: ["test_item"]))

        #expect(viewModel.isFavorited("test_item") == true)
    }

    @Test("toggleFavorite updates favorites")
    func testToggleFavoriteUpdates() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator(initialFavorites: []))

        #expect(viewModel.isFavorited("test_item") == false)

        viewModel.toggleFavorite(for: "test_item")
        await awaitObservation { _ = viewModel.favoriteIds }

        #expect(viewModel.isFavorited("test_item") == true)
    }

    @Test("toggleFavorite removes favorited item")
    func testToggleFavoriteRemoves() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator(initialFavorites: ["test_item"]))

        #expect(viewModel.isFavorited("test_item") == true)

        viewModel.toggleFavorite(for: "test_item")
        await awaitObservation { _ = viewModel.favoriteIds }

        #expect(viewModel.isFavorited("test_item") == false)
    }

    // MARK: - Feature Toggle Tests (Parameterized)

    @Test("Carousel visibility matches feature toggle", arguments: FeatureScenario.carouselScenarios)
    func testCarouselVisibility(scenario: FeatureScenario) async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator(scenario: scenario))

        #expect(viewModel.isCarouselEnabled == scenario.carousel)
    }

    @Test("Mock feature toggle service supports appearanceMode")
    func testMockFeatureToggleAppearanceMode() async {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(MockFavoritesService(), for: .favorites)
        locator.register(MockFeatureToggleService(appearanceMode: .dark), for: .featureToggles)
        locator.register(MockToastService(), for: .toast)

        let service: FeatureToggleServiceProtocol = locator.resolve(for: .featureToggles)
        #expect(service.appearanceMode == .dark)
    }

    @Test("Loading behavior based on error simulation", arguments: FeatureScenario.errorScenarios)
    func testLoadingBehavior(scenario: FeatureScenario) async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator(scenario: scenario))

        await viewModel.loadFeaturedItems()

        #expect(viewModel.hasError == scenario.simulateErrors)
        #expect(viewModel.featuredItems.isEmpty == scenario.simulateErrors)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Refresh Tests

    @Test("refresh reloads featured items")
    func testRefreshReloadsItems() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())

        await viewModel.refresh()

        #expect(!viewModel.featuredItems.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.hasError == false)
    }

    // MARK: - Retry Tests

    @Test("retry calls loadFeaturedItems")
    func testRetryCallsLoad() async {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator(simulateErrors: false))

        // Clear items
        viewModel.hasError = true

        // Retry
        viewModel.retry()

        await Task.yield()

        #expect(!viewModel.featuredItems.isEmpty)
        #expect(viewModel.hasError == false)
    }

}
}
