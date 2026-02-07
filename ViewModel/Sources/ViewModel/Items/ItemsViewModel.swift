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

    // MARK: - Coordinator

    private weak var coordinator: ItemsCoordinator?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService
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
    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(coordinator: ItemsCoordinator?) {
        self.coordinator = coordinator
        loadItems()
        observeFavoritesChanges()
        setupSearchBinding()
    }

    deinit {
        searchTask?.cancel()
    }

    // MARK: - Setup

    private func setupSearchBinding() {
        // Debounce search text with minimum character requirement
        $searchText
            .dropFirst() // Skip initial value
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

                if trimmed.isEmpty {
                    // Empty search - show all items
                    self.needsMoreCharacters = false
                    self.performSearch()
                } else if trimmed.count < self.minimumSearchCharacters {
                    // Below minimum - clear results and show "keep typing"
                    self.needsMoreCharacters = true
                    self.items = []
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

    public func loadItems() {
        // Use the same items as the carousel for consistency
        allItems = FeaturedItem.allCarouselSets.flatMap { $0 }
        let cats = Set(allItems.map { $0.category })
        categories = [L10n.Items.categoryAll] + cats.sorted()
        filterResults()
    }

    /// Perform async search with simulated network delay
    private func performSearch() {
        // Cancel any existing search task
        searchTask?.cancel()

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // If search is empty, just filter immediately without loading state
        if trimmedSearch.isEmpty {
            isSearching = false
            filterResults()
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            // Show loading state
            self.isSearching = true

            // Simulate network delay (300-800ms)
            let delay = UInt64.random(in: 300_000_000...800_000_000)
            try? await Task.sleep(nanoseconds: delay)

            // Check if task was cancelled
            guard !Task.isCancelled else { return }

            // Check if error simulation is enabled
            if self.featureToggleService.simulateErrors {
                self.isSearching = false
                self.hasError = true
                self.items = []
                let errorMessage = AppError.networkError.errorDescription ?? L10n.Error.unknownError
                self.toastService.showToast(message: errorMessage, type: .error)
                return
            }

            // Clear any previous error state
            self.hasError = false

            // Perform filtering
            self.filterResults()
            self.isSearching = false
        }
    }

    private func filterResults() {
        var results = allItems

        // Filter by category (if not "All")
        if selectedCategory != L10n.Items.categoryAll {
            results = results.filter { $0.category == selectedCategory }
        }

        // Filter by search text (case-insensitive)
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedSearch.isEmpty {
            results = results.filter { item in
                item.title.lowercased().contains(trimmedSearch) ||
                item.subtitle.lowercased().contains(trimmedSearch)
            }
        }

        items = results
        logger.log("Filtered to \(results.count) results for: '\(searchText)' in category: '\(selectedCategory)'")
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
        coordinator?.showDetail(for: item)
    }
}
