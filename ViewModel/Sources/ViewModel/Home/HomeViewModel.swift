//
//  HomeViewModel.swift
//  ViewModel
//
//  ViewModel for Home screen
//

import Foundation
import Observation

import FunCore
import FunModel

@MainActor
@Observable
public class HomeViewModel {

    // MARK: - Navigation Closures

    public var onShowDetail: ((FeaturedItem) -> Void)?
    public var onShowProfile: (() -> Void)?

    // MARK: - Services

    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored @Service(.network) private var networkService: NetworkServiceProtocol
    @ObservationIgnored @Service(.favorites) private var favoritesService: FavoritesServiceProtocol
    @ObservationIgnored @Service(.toast) private var toastService: ToastServiceProtocol
    @ObservationIgnored @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - State

    public var featuredItems: [[FeaturedItem]] = []
    public var currentCarouselIndex: Int = 0
    public var isLoading: Bool = false
    public var isCarouselEnabled: Bool = true
    public var favoriteIds: Set<String> = []
    public var hasError: Bool = false

    // MARK: - Private Properties

    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var carouselObservation: Task<Void, Never>?
    @ObservationIgnored private var favoritesObservation: Task<Void, Never>?
    @ObservationIgnored private var hasLoadedInitialData: Bool = false

    // MARK: - Initialization

    public init(
        onShowDetail: ((FeaturedItem) -> Void)? = nil,
        onShowProfile: (() -> Void)? = nil
    ) {
        self.onShowDetail = onShowDetail
        self.onShowProfile = onShowProfile

        // Initialize from current service values (AsyncStream only emits future changes)
        isCarouselEnabled = featureToggleService.featuredCarousel

        observeFeatureToggleChanges()
        observeFavoritesChanges()

        // Load data asynchronously on init
        loadTask = Task { [weak self] in
            await self?.loadFeaturedItems()
        }
    }

    deinit {
        loadTask?.cancel()
        carouselObservation?.cancel()
        favoritesObservation?.cancel()
    }

    // MARK: - Feature Toggle Observation

    private func observeFeatureToggleChanges() {
        let stream = featureToggleService.featuredCarouselChanges
        carouselObservation = Task { [weak self] in
            for await newValue in stream {
                guard let self else { break }
                self.isCarouselEnabled = newValue
                self.logger.log("Carousel visibility changed to: \(newValue)")
            }
        }
    }

    // MARK: - Favorites Observation

    private func observeFavoritesChanges() {
        // Initialize with current favorites
        favoriteIds = favoritesService.favorites

        // Observe future changes
        let stream = favoritesService.favoritesChanges
        favoritesObservation = Task { [weak self] in
            for await newFavorites in stream {
                guard let self else { break }
                self.favoriteIds = newFavorites
            }
        }
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

    /// Load featured items from network service
    public func loadFeaturedItems() async {
        // Show loading only for initial load
        if !hasLoadedInitialData {
            isLoading = true
        }

        hasError = false
        logger.log("Loading featured items...")

        do {
            featuredItems = try await networkService.fetchFeaturedItems()
        } catch is CancellationError {
            // Keep existing items when task is cancelled (e.g. by .refreshable)
            logger.log("Featured items load cancelled, keeping existing data")
        } catch {
            hasError = true
            featuredItems = []
            toastService.showToast(message: AppError.networkError.errorDescription ?? L10n.Error.unknownError, type: .error)
        }

        isLoading = false
        hasLoadedInitialData = true

        logger.log("Featured items loaded: \(featuredItems.flatMap { $0 }.count) items")
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
        onShowDetail?(item)
    }

    public func didTapProfile() {
        logger.log("Profile tapped")
        onShowProfile?()
    }
}
