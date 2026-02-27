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

extension ViewModelTestSuite {

@Suite("ItemsViewModel Tests")
@MainActor
struct ItemsViewModelTests {

    // MARK: - Setup

    private func makeSession(
        initialFavorites: Set<String> = [],
        simulateErrors: Bool = false,
        networkService: MockNetworkService? = nil
    ) -> MockSession {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(networkService ?? MockNetworkService(shouldThrowError: simulateErrors), for: .network)
        locator.register(MockFavoritesService(initialFavorites: initialFavorites), for: .favorites)
        locator.register(MockFeatureToggleService(simulateErrors: simulateErrors), for: .featureToggles)
        locator.register(MockToastService(), for: .toast)
        return MockSession(serviceLocator: locator)
    }

    // MARK: - Initialization Tests

    @Test("Items are loaded on initialization")
    func testItemsLoadedOnInit() async {
        let viewModel = ItemsViewModel(session: makeSession())
        await viewModel.loadItems()

        #expect(viewModel.items.isEmpty == false)
    }

    @Test("Initial search text is empty")
    func testInitialSearchTextEmpty() async {
        let viewModel = ItemsViewModel(session: makeSession())

        #expect(viewModel.searchText.isEmpty)
    }

    @Test("Initial selected category is 'All'")
    func testInitialCategoryIsAll() async {
        let viewModel = ItemsViewModel(session: makeSession())

        #expect(viewModel.selectedCategory == "All")
    }

    @Test("Initial isSearching is false")
    func testInitialIsSearchingFalse() async {
        let viewModel = ItemsViewModel(session: makeSession())

        #expect(viewModel.isSearching == false)
    }

    @Test("Minimum search characters is 2")
    func testMinimumSearchCharacters() async {
        let viewModel = ItemsViewModel(session: makeSession())

        #expect(viewModel.minimumSearchCharacters == 2)
    }

    // MARK: - Category Tests

    @Test("Categories include 'All' as first option")
    func testCategoriesIncludeAll() async {
        let viewModel = ItemsViewModel(session: makeSession())
        await viewModel.loadItems()

        #expect(viewModel.categories.first == "All")
    }

    @Test("Selecting a category updates selectedCategory")
    func testSelectCategoryUpdatesState() async throws {
        let viewModel = ItemsViewModel(session: makeSession())
        await viewModel.loadItems()

        let categories = viewModel.categories
        try #require(categories.count > 1)

        let categoryToSelect = categories[1]
        viewModel.didSelectCategory(categoryToSelect)

        #expect(viewModel.selectedCategory == categoryToSelect)
    }

    @Test("Selecting 'All' shows all items")
    func testSelectAllShowsAllItems() async {
        let viewModel = ItemsViewModel(session: makeSession())
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
        let viewModel = ItemsViewModel(session: makeSession())

        viewModel.searchText = "test"
        viewModel.clearSearch()

        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.isSearching == false)
    }

    @Test("Initial needsMoreCharacters is false")
    func testInitialNeedsMoreCharactersFalse() async {
        let viewModel = ItemsViewModel(session: makeSession())

        #expect(viewModel.needsMoreCharacters == false)
    }

    // MARK: - Favorites Tests

    @Test("isFavorited returns false for unfavorited item")
    func testIsFavoritedReturnsFalse() async {
        let viewModel = ItemsViewModel(session: makeSession(initialFavorites: []))

        #expect(viewModel.isFavorited("unfavorited_item") == false)
    }

    @Test("isFavorited returns true for favorited item")
    func testIsFavoritedReturnsTrue() async {
        let viewModel = ItemsViewModel(session: makeSession(initialFavorites: ["test_item"]))

        #expect(viewModel.isFavorited("test_item") == true)
    }

    @Test("toggleFavorite adds unfavorited item to favorites")
    func testToggleFavoriteAdds() async {
        let viewModel = ItemsViewModel(session: makeSession(initialFavorites: []))

        // Let observation tasks subscribe to streams
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.isFavorited("test_item") == false)

        viewModel.toggleFavorite(for: "test_item")

        // Wait for AsyncStream to deliver
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.isFavorited("test_item") == true)
    }

    @Test("toggleFavorite removes favorited item from favorites")
    func testToggleFavoriteRemoves() async {
        let viewModel = ItemsViewModel(session: makeSession(initialFavorites: ["test_item"]))

        // Let observation tasks subscribe to streams
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.isFavorited("test_item") == true)

        viewModel.toggleFavorite(for: "test_item")

        // Wait for AsyncStream to deliver
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.isFavorited("test_item") == false)
    }

    // MARK: - Favorites Publisher Tests

    @Test("ViewModel updates favoriteIds when service changes")
    func testViewModelObservesFavoritesChanges() async {
        let mockFavorites = MockFavoritesService(initialFavorites: [])
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(mockFavorites, for: .favorites)
        locator.register(MockFeatureToggleService(), for: .featureToggles)
        locator.register(MockToastService(), for: .toast)

        let viewModel = ItemsViewModel(session: MockSession(serviceLocator: locator))

        // Let observation tasks subscribe to streams
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.favoriteIds.isEmpty)

        // Add favorite directly on the service
        mockFavorites.addFavorite("new_item")

        // Wait for AsyncStream to deliver
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.favoriteIds.contains("new_item"))
    }

    // MARK: - Coordinator Tests

    @Test("didSelectItem calls onShowDetail closure")
    func testDidSelectItemCallsClosure() async throws {
        var showDetailItem: FeaturedItem?
        let viewModel = ItemsViewModel(session: makeSession())
        viewModel.onShowDetail = { item in showDetailItem = item }
        await viewModel.loadItems()

        let item = try #require(viewModel.items.first)

        viewModel.didSelectItem(item)

        #expect(showDetailItem?.id == item.id)
    }

    // MARK: - Filter Behavior Tests

    @Test("Filtering by category reduces item count")
    func testCategoryFilterReducesItems() async {
        let viewModel = ItemsViewModel(session: makeSession())
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
        let viewModel = ItemsViewModel(session: makeSession())
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

    // MARK: - Network Search Tests

    @Test("Search calls networkService.searchItems with query and category")
    func testSearchCallsNetworkService() async throws {
        let mockNetwork = MockNetworkService(stubbedSearchItems: [.swiftUI])
        let viewModel = ItemsViewModel(session: makeSession(networkService: mockNetwork))
        await viewModel.loadItems()

        viewModel.searchText = "swift"
        // Trigger search directly by calling the debounced path
        viewModel.didSelectCategory(viewModel.selectedCategory)

        // Wait for the search task to complete
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockNetwork.searchItemsCallCount == 1)
        #expect(mockNetwork.lastSearchQuery == "swift")
        #expect(mockNetwork.lastSearchCategory == "All")
        #expect(viewModel.items == [.swiftUI])
        #expect(viewModel.isSearching == false)
    }

    @Test("Search error sets hasError and shows toast")
    func testSearchErrorSetsHasError() async throws {
        let mockNetwork = MockNetworkService(shouldThrowError: true)
        let mockToast = MockToastService()
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(mockNetwork, for: .network)
        locator.register(MockFavoritesService(), for: .favorites)
        locator.register(MockFeatureToggleService(), for: .featureToggles)
        locator.register(mockToast, for: .toast)
        let session = MockSession(serviceLocator: locator)
        let viewModel = ItemsViewModel(session: session)

        viewModel.searchText = "swift"
        viewModel.didSelectCategory(viewModel.selectedCategory)

        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.hasError == true)
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.isSearching == false)

        // Use local ref, not ServiceLocator which may be reset by parallel tests
        #expect(mockToast.showToastCalled == true)
    }

    @Test("Clear search resets to filtered allItems")
    func testClearSearchResetsToAllItems() async throws {
        let mockNetwork = MockNetworkService(stubbedSearchItems: [.swiftUI])
        let viewModel = ItemsViewModel(session: makeSession(networkService: mockNetwork))
        await viewModel.loadItems()

        let allItemsCount = viewModel.items.count

        // Perform a search
        viewModel.searchText = "swift"
        viewModel.didSelectCategory(viewModel.selectedCategory)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(viewModel.items.count == 1)

        // Clear search
        viewModel.clearSearch()
        #expect(viewModel.items.count == allItemsCount)
        #expect(viewModel.hasError == false)
    }

    // MARK: - Error State Tests

    @Test("Initial hasError is false")
    func testInitialHasErrorFalse() async {
        let viewModel = ItemsViewModel(session: makeSession())

        #expect(viewModel.hasError == false)
    }

    @Test("Mock feature toggle service returns correct simulateErrors value")
    func testMockFeatureToggleSimulateErrors() async {
        let session = makeSession(simulateErrors: true)

        let service: FeatureToggleServiceProtocol = session.serviceLocator.resolve(for: .featureToggles)
        #expect(service.simulateErrors == true)
    }


    @Test("clearSearch always sets hasError to false")
    func testClearSearchSetsHasErrorFalse() async {
        let viewModel = ItemsViewModel(session: makeSession(simulateErrors: true))

        // Manually set hasError to true to simulate error state
        viewModel.hasError = true

        // Clear search
        viewModel.clearSearch()

        #expect(viewModel.hasError == false)
    }

    @Test("retry resets hasError before re-searching")
    func testRetryResetsHasError() async {
        let viewModel = ItemsViewModel(session: makeSession(simulateErrors: false))

        // Manually set hasError to true
        viewModel.hasError = true

        // Retry should clear the error flag
        viewModel.retry()

        // hasError should be cleared immediately when retry is called
        // (even though the search is async)
        #expect(viewModel.hasError == false)
    }
}
}
