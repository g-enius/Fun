//
//  ItemsViewModel.swift
//  ViewModel
//
//  ViewModel for Items screen - combines search, filter, and items list
//

import Combine
import Foundation

import FunCore
import FunModel

@MainActor
public class ItemsViewModel: ObservableObject {

    // MARK: - Navigation Closures

    public var onShowDetail: ((FeaturedItem) -> Void)?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService
    @Service(.network) private var networkService: NetworkService
    @Service(.favorites) private var favoritesService: FavoritesServiceProtocol
    @Service(.toast) private var toastService: ToastServiceProtocol
    @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - Published State

    @Published public var items: [FeaturedItem] = []
    @Published public private(set) var favoriteIds: Set<String> = []

    // Search & Filter State
    @Published public var searchText: String = ""
    @Published public var selectedCategory: String = L10n.Items.categoryAll
    @Published public var isSearching: Bool = false
    @Published public var needsMoreCharacters: Bool = false
    @Published public var hasError: Bool = false

    // MARK: - Configuration

    public private(set) var categories: [String] = [L10n.Items.categoryAll]
    public let minimumSearchCharacters: Int = 2

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var allItems: [FeaturedItem] = []
    private var loadTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(onShowDetail: ((FeaturedItem) -> Void)? = nil) {
        self.onShowDetail = onShowDetail
        observeFavoritesChanges()
        setupSearchBinding()

        loadTask = Task { [weak self] in
            await self?.loadItems()
        }
    }

    deinit {
        loadTask?.cancel()
        searchTask?.cancel()
    }

    // MARK: - Setup

    private func setupSearchBinding() {
        // Debounce search text with minimum character requirement
        $searchText
            .dropFirst() // Skip initial value
            .debounce(for: .milliseconds(600), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

                if trimmed.isEmpty {
                    // Empty search - show all items
                    self.needsMoreCharacters = false
                    self.performSearch()
                } else if trimmed.count < self.minimumSearchCharacters {
                    // Below minimum - show "keep typing" unless in error state
                    if !self.hasError {
                        self.needsMoreCharacters = true
                        self.items = []
                    }
                    self.isSearching = false
                } else {
                    // Meets minimum - perform search
                    self.needsMoreCharacters = false
                    self.performSearch()
                }
            }
            .store(in: &cancellables)
    }

    private func observeFavoritesChanges() {
        // Initialize with current favorites
        favoriteIds = favoritesService.favorites

        // Observe future changes
        favoritesService.favoritesDidChange
            .sink { [weak self] newFavorites in
                self?.favoriteIds = newFavorites
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

    public func loadItems() async {
        allItems = (try? await networkService.fetchAllItems()) ?? []
        let cats = Set(allItems.map { $0.category })
        categories = [L10n.Items.categoryAll] + cats.sorted()

        if featureToggleService.simulateErrors {
            hasError = true
            items = []
        } else {
            filterResults()
        }
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
