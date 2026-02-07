//
//  HomeViewModel.swift
//  ViewModel
//
//  ViewModel for Home screen
//

import Combine
import Foundation

import FunCore
import FunModel

@MainActor
public class HomeViewModel: ObservableObject {

    // MARK: - Coordinator

    private weak var coordinator: HomeCoordinator?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService
    @Service(.favorites) private var favoritesService: FavoritesServiceProtocol
    @Service(.toast) private var toastService: ToastServiceProtocol

    @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - Published State

    @Published public var featuredItems: [[FeaturedItem]] = []
    @Published public var currentCarouselIndex: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var isCarouselEnabled: Bool = true
    @Published public private(set) var favoriteIds: Set<String> = []
    @Published public var hasError: Bool = false

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?
    private var hasLoadedInitialData: Bool = false

    // MARK: - Initialization

    public init(coordinator: HomeCoordinator?) {
        self.coordinator = coordinator

        observeFeatureToggleChanges()
        observeFavoritesChanges()

        // Load data asynchronously on init
        loadTask = Task { [weak self] in
            await self?.loadFeaturedItems()
        }
    }

    deinit {
        loadTask?.cancel()
    }

    // MARK: - Feature Toggle Observation (Combine)

    private func observeFeatureToggleChanges() {
        featureToggleService.featuredCarouselPublisher
            .sink { [weak self] newValue in
                self?.isCarouselEnabled = newValue
                self?.logger.log("Carousel visibility changed to: \(newValue)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Favorites Observation

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

    // MARK: - Favorites

    public func isFavorited(_ itemId: String) -> Bool {
        favoriteIds.contains(itemId)
    }

    public func toggleFavorite(for itemId: String) {
        favoritesService.toggleFavorite(itemId)
        logger.log("Toggled favorite for: \(itemId)")
    }

    // MARK: - Data Loading

    /// Load featured items with simulated network delay
    public func loadFeaturedItems() async {
        // Check if error simulation is enabled
        if featureToggleService.simulateErrors {
            await handleSimulatedError()
            return
        }

        // Show loading only for initial load
        if !hasLoadedInitialData {
            isLoading = true
        }

        hasError = false
        logger.log("Loading featured items...")

        // Simulate network delay (500ms - 1.5s)
        let delay = UInt64.random(in: 500_000_000...1_500_000_000)
        try? await Task.sleep(nanoseconds: delay)

        // Use static FeaturedItem data showcasing technologies used in this demo
        featuredItems = FeaturedItem.allCarouselSets
        isLoading = false
        hasLoadedInitialData = true

        logger.log("Featured items loaded: \(featuredItems.flatMap { $0 }.count) items")
    }

    private func handleSimulatedError() async {
        logger.log("Simulating network error...")

        // Simulate network delay
        let delay = UInt64.random(in: 500_000_000...1_000_000_000)
        try? await Task.sleep(nanoseconds: delay)

        hasError = true
        isLoading = false
        featuredItems = []

        toastService.showToast(message: AppError.networkError.errorDescription ?? L10n.Error.unknownError, type: .error)
    }

    /// Pull-to-refresh handler
    public func refresh() async {
        logger.log("Pull to refresh triggered")
        await loadFeaturedItems()
    }

    /// Retry loading after error
    public func retry() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadFeaturedItems()
        }
    }

    // MARK: - Actions

    public func didTapFeaturedItem(_ item: FeaturedItem) {
        logger.log("Featured item tapped: \(item.title)")
        coordinator?.showDetail(for: item)
    }

    public func didTapProfile() {
        logger.log("Profile tapped")
        coordinator?.showProfile()
    }
}
