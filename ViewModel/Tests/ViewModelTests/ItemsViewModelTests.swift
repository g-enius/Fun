//
//  ItemsViewModelTests.swift
//  ViewModel
//
//  Unit tests for ItemsViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

@Suite("ItemsViewModel Tests", .serialized)
@MainActor
struct ItemsViewModelTests {

    // MARK: - Setup

    private func setupServices(initialFavorites: Set<String> = [], simulateErrors: Bool = false) {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockNetworkService(), for: .network)
        ServiceLocator.shared.register(MockFavoritesService(initialFavorites: initialFavorites), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(simulateErrors: simulateErrors), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // MARK: - Initialization Tests

    @Test("Items are loaded on initialization")
    func testItemsLoadedOnInit() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)
        await viewModel.loadItems()

        #expect(viewModel.items.isEmpty == false)
    }

    @Test("Initial search text is empty")
    func testInitialSearchTextEmpty() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.searchText.isEmpty)
    }

    @Test("Initial selected category is 'All'")
    func testInitialCategoryIsAll() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.selectedCategory == "All")
    }

    @Test("Initial isSearching is false")
    func testInitialIsSearchingFalse() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.isSearching == false)
    }

    @Test("Minimum search characters is 2")
    func testMinimumSearchCharacters() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.minimumSearchCharacters == 2)
    }

    // MARK: - Category Tests

    @Test("Categories include 'All' as first option")
    func testCategoriesIncludeAll() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)
        await viewModel.loadItems()

        #expect(viewModel.categories.first == "All")
    }

    @Test("Selecting a category updates selectedCategory")
    func testSelectCategoryUpdatesState() async throws {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)
        await viewModel.loadItems()

        let categories = viewModel.categories
        try #require(categories.count > 1)

        let categoryToSelect = categories[1]
        viewModel.didSelectCategory(categoryToSelect)

        #expect(viewModel.selectedCategory == categoryToSelect)
    }

    @Test("Selecting 'All' shows all items")
    func testSelectAllShowsAllItems() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)
        await viewModel.loadItems()

        // Get initial item count (with All selected)
        let allItemsCount = viewModel.items.count

        // Select a specific category
        if viewModel.categories.count > 1 {
            viewModel.didSelectCategory(viewModel.categories[1])
        }

        // Go back to All
        viewModel.didSelectCategory("All")

        #expect(viewModel.items.count == allItemsCount)
    }

    // MARK: - Search Tests

    @Test("Clear search resets search text and isSearching")
    func testClearSearchResetsState() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)

        viewModel.searchText = "test"
        viewModel.clearSearch()

        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.isSearching == false)
    }

    @Test("Initial needsMoreCharacters is false")
    func testInitialNeedsMoreCharactersFalse() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.needsMoreCharacters == false)
    }

    // MARK: - Favorites Tests

    @Test("isFavorited returns false for unfavorited item")
    func testIsFavoritedReturnsFalse() async {
        setupServices(initialFavorites: [])
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.isFavorited("unfavorited_item") == false)
    }

    @Test("isFavorited returns true for favorited item")
    func testIsFavoritedReturnsTrue() async {
        setupServices(initialFavorites: ["test_item"])
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.isFavorited("test_item") == true)
    }

    @Test("toggleFavorite adds unfavorited item to favorites")
    func testToggleFavoriteAdds() async {
        setupServices(initialFavorites: [])
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.isFavorited("test_item") == false)

        viewModel.toggleFavorite(for: "test_item")

        // Wait for publisher to propagate
        await Task.yield()

        #expect(viewModel.isFavorited("test_item") == true)
    }

    @Test("toggleFavorite removes favorited item from favorites")
    func testToggleFavoriteRemoves() async {
        setupServices(initialFavorites: ["test_item"])
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.isFavorited("test_item") == true)

        viewModel.toggleFavorite(for: "test_item")

        // Wait for publisher to propagate
        await Task.yield()

        #expect(viewModel.isFavorited("test_item") == false)
    }

    // MARK: - Favorites Publisher Tests

    @Test("ViewModel updates favoriteIds when service changes")
    func testViewModelObservesFavoritesChanges() async {
        setupServices(initialFavorites: [])
        let mockFavorites = MockFavoritesService(initialFavorites: [])
        ServiceLocator.shared.register(mockFavorites, for: .favorites)

        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.favoriteIds.isEmpty)

        // Add favorite directly on the service
        mockFavorites.addFavorite("new_item")

        // Wait for publisher to propagate
        await Task.yield()

        #expect(viewModel.favoriteIds.contains("new_item"))
    }

    // MARK: - Coordinator Tests

    @Test("didSelectItem calls coordinator showDetail")
    func testDidSelectItemCallsCoordinator() async throws {
        setupServices()
        let mockCoordinator = MockTabCoordinator()
        let viewModel = ItemsViewModel(coordinator: mockCoordinator)
        await viewModel.loadItems()

        let item = try #require(viewModel.items.first)

        viewModel.didSelectItem(item)

        #expect(mockCoordinator.showDetailCalled == true)
        #expect(mockCoordinator.showDetailItem?.id == item.id)
    }

    // MARK: - Filter Behavior Tests

    @Test("Filtering by category reduces item count")
    func testCategoryFilterReducesItems() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)
        await viewModel.loadItems()

        let allItemsCount = viewModel.items.count

        // Find a category that has fewer items than all
        let categories = viewModel.categories.filter { $0 != "All" }
        guard let testCategory = categories.first else {
            return
        }

        viewModel.didSelectCategory(testCategory)

        let filteredCount = viewModel.items.count

        // Category filter should show <= all items
        #expect(filteredCount <= allItemsCount)
    }

    @Test("Items in filtered list match selected category")
    func testFilteredItemsMatchCategory() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)
        await viewModel.loadItems()

        let categories = viewModel.categories.filter { $0 != "All" }
        guard let testCategory = categories.first else {
            return
        }

        viewModel.didSelectCategory(testCategory)

        for item in viewModel.items {
            #expect(item.category == testCategory)
        }
    }

    // MARK: - Error State Tests

    @Test("Initial hasError is false")
    func testInitialHasErrorFalse() async {
        setupServices()
        let viewModel = ItemsViewModel(coordinator: nil)

        #expect(viewModel.hasError == false)
    }

    @Test("Mock feature toggle service returns correct simulateErrors value")
    func testMockFeatureToggleSimulateErrors() async {
        setupServices(simulateErrors: true)

        let service: FeatureToggleServiceProtocol = ServiceLocator.shared.resolve(for: .featureToggles)
        #expect(service.simulateErrors == true)
    }


    @Test("clearSearch always sets hasError to false")
    func testClearSearchSetsHasErrorFalse() async {
        setupServices(simulateErrors: true)
        let viewModel = ItemsViewModel(coordinator: nil)

        // Manually set hasError to true to simulate error state
        viewModel.hasError = true

        // Clear search
        viewModel.clearSearch()

        #expect(viewModel.hasError == false)
    }

    @Test("retry resets hasError before re-searching")
    func testRetryResetsHasError() async {
        setupServices(simulateErrors: false)
        let viewModel = ItemsViewModel(coordinator: nil)

        // Manually set hasError to true
        viewModel.hasError = true

        // Retry should clear the error flag
        viewModel.retry()

        // hasError should be cleared immediately when retry is called
        // (even though the search is async)
        #expect(viewModel.hasError == false)
    }
}
