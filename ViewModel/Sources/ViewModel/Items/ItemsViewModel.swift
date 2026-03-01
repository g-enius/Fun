//
//  ItemsViewModel.swift
//  ViewModel
//
//  ViewModel for Items screen - combines search, filter, and items list
//

import Foundation
import Observation

import FunCore
import FunModel

@MainActor
@Observable
public class ItemsViewModel {

    // MARK: - Navigation Closures

    public var onShowDetail: ((FeaturedItem) -> Void)?

    // MARK: - Services

    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored @Service(.network) private var networkService: NetworkService
    @ObservationIgnored @Service(.favorites) private var favoritesService: FavoritesServiceProtocol
    @ObservationIgnored @Service(.toast) private var toastService: ToastServiceProtocol
    @ObservationIgnored @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - State

    public var items: [FeaturedItem] = []
    public var favoriteIds: Set<String> = []

    // Search & Filter State
    public var searchText: String = "" {
        didSet { handleSearchTextChanged() }
    }
    public var selectedCategory: String = L10n.Items.categoryAll
    public var isSearching: Bool = false
    public var needsMoreCharacters: Bool = false
    public var hasError: Bool = false
    public private(set) var isLoading: Bool = false

    // MARK: - Configuration

    public private(set) var categories: [String] = [L10n.Items.categoryAll]
    public let minimumSearchCharacters: Int = 2

    // MARK: - Private Properties

    @ObservationIgnored private var allItems: [FeaturedItem] = []
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private var debounceTask: Task<Void, Never>?
    @ObservationIgnored private var favoritesObservation: Task<Void, Never>?

    // MARK: - Initialization

    public init(onShowDetail: ((FeaturedItem) -> Void)? = nil) {
        self.onShowDetail = onShowDetail
        observeFavoritesChanges()

        loadTask = Task { [weak self] in
            await self?.loadItems()
        }
    }

    deinit {
        loadTask?.cancel()
        searchTask?.cancel()
        debounceTask?.cancel()
        favoritesObservation?.cancel()
    }

    // MARK: - Setup

    private func handleSearchTextChanged() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled, let self else { return }
            self.processSearchText()
        }
    }

    private func processSearchText() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            needsMoreCharacters = false
            performSearch()
        } else if trimmed.count < minimumSearchCharacters {
            if !hasError {
                needsMoreCharacters = true
                items = []
            }
            isSearching = false
        } else {
            needsMoreCharacters = false
            performSearch()
        }
    }

    private func observeFavoritesChanges() {
        // Initialize with current favorites
        favoriteIds = favoritesService.favorites

        // Observe future changes
        let stream = favoritesService.favoritesStream
        favoritesObservation = Task { [weak self] in
            for await newFavorites in stream {
                guard let self else { break }
                self.favoriteIds = newFavorites
            }
        }
    }

    // MARK: - Data Loading

    public func loadItems() async {
        isLoading = true
        defer { isLoading = false }

        do {
            allItems = try await networkService.fetchAllItems()
        } catch is CancellationError {
            allItems = []
            return
        } catch {
            hasError = true
            items = []
            return
        }

        let cats = Set(allItems.map { $0.category })
        categories = [L10n.Items.categoryAll] + cats.sorted()
        filterResults()
    }

    /// Perform async search via network service
    private func performSearch() {
        // Cancel any existing search task
        searchTask?.cancel()

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // If search is empty, show all items unless in error state
        if trimmedSearch.isEmpty {
            isSearching = false
            if !hasError {
                filterResults()
            }
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            self.isSearching = true

            do {
                let results = try await self.networkService.searchItems(
                    query: trimmedSearch,
                    category: self.selectedCategory
                )

                guard !Task.isCancelled else { return }

                self.hasError = false
                self.items = results
                self.logger.log(
                    "Search returned \(results.count) results for: '\(trimmedSearch)'"
                )
            } catch {
                guard !Task.isCancelled else { return }

                self.hasError = true
                self.items = []
                let errorMessage = AppError.networkError.errorDescription ?? L10n.Error.unknownError
                self.toastService.showToast(message: errorMessage, type: .error)
            }

            self.isSearching = false
        }
    }

    private func filterResults() {
        var results = allItems

        // Filter by category (if not "All")
        if selectedCategory != L10n.Items.categoryAll {
            results = results.filter { $0.category == selectedCategory }
        }

        items = results
        logger.log("Filtered to \(results.count) results in category: '\(selectedCategory)'")
    }

    // MARK: - Search Actions

    public func clearSearch() {
        searchText = ""
        debounceTask?.cancel()
        searchTask?.cancel()
        isSearching = false
        hasError = false
        filterResults()
    }

    public func retry() {
        hasError = false
        performSearch()
    }

    public func didSelectCategory(_ category: String) {
        selectedCategory = category
        logger.log("Category selected: \(category)")
        performSearch()
    }

    // MARK: - Favorites

    public func isFavorited(_ itemId: String) -> Bool {
        favoriteIds.contains(itemId)
    }

    public func toggleFavorite(for itemId: String) {
        favoritesService.toggleFavorite(itemId)
    }

    // MARK: - Actions

    public func didSelectItem(_ item: FeaturedItem) {
        logger.log("Item selected: \(item.title)")
        onShowDetail?(item)
    }
}
