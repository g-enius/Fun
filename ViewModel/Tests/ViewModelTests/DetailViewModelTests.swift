//
//  DetailViewModelTests.swift
//  ViewModel
//
//  Unit tests for DetailViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

@Suite("DetailViewModel Tests", .serialized)
@MainActor
struct DetailViewModelTests {

    // MARK: - Setup

    private func setupServices(initialFavorites: Set<String> = []) {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesService(initialFavorites: initialFavorites), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    private var testItem: FeaturedItem {
        FeaturedItem.asyncAwait
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches item data")
    func testInitialStateMatchesItem() async {
        setupServices()
        let item = testItem
        let viewModel = DetailViewModel(item: item, coordinator: nil)

        #expect(viewModel.itemTitle == item.title)
        #expect(viewModel.category == item.category)
        #expect(viewModel.itemDescription == TechnologyDescriptions.description(for: item.id))
    }

    @Test("isFavorited is true when item is in favorites")
    func testIsFavoritedTrue() async {
        let item = testItem
        setupServices(initialFavorites: [item.id])
        let viewModel = DetailViewModel(item: item, coordinator: nil)

        #expect(viewModel.isFavorited == true)
    }

    @Test("isFavorited is false when item is not in favorites")
    func testIsFavoritedFalse() async {
        setupServices(initialFavorites: [])
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        #expect(viewModel.isFavorited == false)
    }

    // MARK: - Toggle Favorite Tests

    @Test("didTapToggleFavorite adds item to favorites")
    func testToggleFavoriteAdds() async {
        setupServices(initialFavorites: [])
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        #expect(viewModel.isFavorited == false)

        viewModel.didTapToggleFavorite()

        // Wait for publisher to propagate
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.isFavorited == true)
    }

    @Test("didTapToggleFavorite removes item from favorites")
    func testToggleFavoriteRemoves() async {
        let item = testItem
        setupServices(initialFavorites: [item.id])
        let viewModel = DetailViewModel(item: item, coordinator: nil)

        #expect(viewModel.isFavorited == true)

        viewModel.didTapToggleFavorite()

        // Wait for publisher to propagate
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.isFavorited == false)
    }

    // MARK: - Favorites Observation Tests

    @Test("ViewModel updates when favorites service changes externally")
    func testExternalFavoritesChange() async {
        setupServices(initialFavorites: [])
        let mockFavorites = MockFavoritesService(initialFavorites: [])
        ServiceLocator.shared.register(mockFavorites, for: .favorites)

        let item = testItem
        let viewModel = DetailViewModel(item: item, coordinator: nil)

        #expect(viewModel.isFavorited == false)

        // Change favorites externally
        mockFavorites.addFavorite(item.id)

        // Wait for publisher
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.isFavorited == true)
    }

    // MARK: - Share Tests

    @Test("didTapShare calls coordinator share")
    func testDidTapShareCallsCoordinator() async {
        setupServices()
        let coordinator = MockDetailCoordinator()
        let viewModel = DetailViewModel(item: testItem, coordinator: coordinator)

        viewModel.didTapShare()

        #expect(coordinator.shareCalled == true)
        #expect(coordinator.lastShareText != nil)
        #expect(coordinator.lastShareText?.contains(testItem.title) == true)
    }

    // MARK: - Back Navigation Tests

    @Test("handleBackNavigation calls coordinator handleSystemDismiss")
    func testHandleBackNavigationCallsCoordinator() async {
        setupServices()
        let coordinator = MockDetailCoordinator()
        let viewModel = DetailViewModel(item: testItem, coordinator: coordinator)

        viewModel.handleBackNavigation()

        #expect(coordinator.handleSystemDismissCalled == true)
        #expect(coordinator.dismissCalled == false) // Should NOT call dismiss()
    }

    @Test("handleBackNavigation with nil coordinator does not crash")
    func testHandleBackNavigationWithNilCoordinator() async {
        setupServices()
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        viewModel.handleBackNavigation() // Should not crash
    }

    // MARK: - Different Items Tests

    @Test("Works with different featured items")
    func testDifferentItems() async {
        setupServices()

        let items: [FeaturedItem] = [.swiftUI, .combine, .mvvm, .coordinator]
        for item in items {
            let viewModel = DetailViewModel(item: item, coordinator: nil)
            #expect(viewModel.itemTitle == item.title)
            #expect(viewModel.category == item.category)
        }
    }
}
