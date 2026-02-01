//
//  Tab2ViewModelTests.swift
//  ViewModel
//
//  Unit tests for Tab2ViewModel (Search & Filter)
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel

@Suite("Tab2ViewModel Tests")
@MainActor
struct Tab2ViewModelTests {

    // MARK: - Initial State Tests

    @Test("Initial state loads all items")
    func testInitialStateLoadsAllItems() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        #expect(viewModel.searchResults.count == 6)
        #expect(viewModel.selectedCategory == "All")
        #expect(viewModel.searchText.isEmpty)
    }

    @Test("Categories are correctly defined")
    func testCategoriesAreDefined() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        #expect(viewModel.categories == ["All", "Tech", "Design", "Business"])
    }

    // MARK: - Category Filter Tests

    @Test("Selecting Tech category filters to Tech items only")
    func testTechCategoryFilter() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.didSelectCategory("Tech")

        #expect(viewModel.selectedCategory == "Tech")
        #expect(viewModel.searchResults.allSatisfy { $0.category == "Tech" })
        #expect(viewModel.searchResults.count == 2)
    }

    @Test("Selecting Design category filters to Design items only")
    func testDesignCategoryFilter() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.didSelectCategory("Design")

        #expect(viewModel.selectedCategory == "Design")
        #expect(viewModel.searchResults.allSatisfy { $0.category == "Design" })
        #expect(viewModel.searchResults.count == 2)
    }

    @Test("Selecting Business category filters to Business items only")
    func testBusinessCategoryFilter() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.didSelectCategory("Business")

        #expect(viewModel.selectedCategory == "Business")
        #expect(viewModel.searchResults.allSatisfy { $0.category == "Business" })
        #expect(viewModel.searchResults.count == 2)
    }

    @Test("Selecting All category shows all items")
    func testAllCategoryFilter() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        // First filter to Tech
        viewModel.didSelectCategory("Tech")
        #expect(viewModel.searchResults.count == 2)

        // Then select All
        viewModel.didSelectCategory("All")
        #expect(viewModel.selectedCategory == "All")
        #expect(viewModel.searchResults.count == 6)
    }

    // MARK: - Search Text Filter Tests

    @Test("Search text filters by title")
    func testSearchByTitle() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.searchText = "Swift"
        // Manually trigger filter since debounce won't fire immediately in tests
        viewModel.didSelectCategory(viewModel.selectedCategory)

        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.title == "Swift Concurrency")
    }

    @Test("Search text filters by subtitle")
    func testSearchBySubtitle() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.searchText = "harmony"
        viewModel.didSelectCategory(viewModel.selectedCategory)

        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.title == "Color Theory")
    }

    @Test("Search is case insensitive")
    func testCaseInsensitiveSearch() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.searchText = "SWIFT"
        viewModel.didSelectCategory(viewModel.selectedCategory)

        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.title == "Swift Concurrency")
    }

    @Test("Empty search shows all items in selected category")
    func testEmptySearchShowsAll() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.searchText = "Swift"
        viewModel.didSelectCategory(viewModel.selectedCategory)
        #expect(viewModel.searchResults.count == 1)

        viewModel.searchText = ""
        viewModel.didSelectCategory(viewModel.selectedCategory)
        #expect(viewModel.searchResults.count == 6)
    }

    // MARK: - Combined Filter Tests

    @Test("Search and category filter work together")
    func testCombinedSearchAndCategoryFilter() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.searchText = "design"
        viewModel.didSelectCategory("Design")

        // Should find "UI Design" in Design category
        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.title == "UI Design")
    }

    @Test("No results when search doesn't match category")
    func testNoResultsWhenSearchDoesntMatchCategory() async {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        viewModel.searchText = "Swift"  // This is in Tech category
        viewModel.didSelectCategory("Design")  // Filter to Design

        #expect(viewModel.searchResults.isEmpty)
    }
}
