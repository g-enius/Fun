//
//  ItemsViewModel.swift
//  ViewModel
//
//  ViewModel for Items screen - combines search, filter, and items list
//

import Combine
import Foundation
import Observation

import FunCore
import FunModel

@MainActor
@Observable
public class ItemsViewModel: ServiceLocatorProvider {

    // MARK: - Navigation Closures

    @ObservationIgnored public var onShowDetail: ((FeaturedItem) -> Void)?

    // MARK: - DI

    @ObservationIgnored public let serviceLocator: ServiceLocator
    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored @Service(.network) private var networkService: NetworkServiceProtocol
    @ObservationIgnored @Service(.favorites) private var favoritesService: FavoritesServiceProtocol
    @ObservationIgnored @Service(.toast) private var toastService: ToastServiceProtocol
    @ObservationIgnored @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - State

    public var items: [FeaturedItem] = []
    public private(set) var favoriteIds: Set<String> = []

    // Search & Filter State
    public var searchText: String = ""
    public var selectedCategory: String = L10n.Items.categoryAll
    public var isSearching: Bool = false
    public var needsMoreCharacters: Bool = false
    public var hasError: Bool = false
    public private(set) var isLoading: Bool = false

    // MARK: - Configuration

    public private(set) var categories: [String] = [L10n.Items.categoryAll]
    public let minimumSearchCharacters: Int = 2

    // MARK: - Private Properties

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var allItems: [FeaturedItem] = []
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(
        onShowDetail: ((FeaturedItem) -> Void)? = nil,
        serviceLocator: ServiceLocator
    ) {
        self.onShowDetail = onShowDetail
        self.serviceLocator = serviceLocator

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
        // Note: withObservationTracking doesn't provide a publisher, so we keep
        // this Combine pipeline for debounced search. The searchText property is
        // still @Observable for SwiftUI binding; we observe it via a Task.
        observeSearchTextChanges()
    }

    private func observeSearchTextChanges() {
        // Use a recurring observation loop to bridge @Observable → Combine-style debounce
        // This replaces $searchText which is unavailable without @Published
        let subject = PassthroughSubject<String, Never>()

        subject
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
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

        // Bridge @Observable searchText changes into the subject
        func observe() {
            withObservationTracking {
                _ = self.searchText
            } onChange: { [weak self] in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    subject.send(self.searchText)
                    observe()
                }
            }
        }
        observe()
    }

    private func observeFavoritesChanges() {
        // CurrentValueSubject replays current value on subscribe — no manual init needed
        favoritesService.favoritesDidChange
            .sink { [weak self] newFavorites in
                self?.favoriteIds = newFavorites
            }
            .store(in: &cancellables)
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
