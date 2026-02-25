//
//  HomeViewModel.swift
//  ViewModel
//
//  ViewModel for Home screen
//

import Combine
import Foundation
import Observation

import FunCore
import FunModel

@MainActor
@Observable
public class HomeViewModel: ServiceLocatorProvider {

    // MARK: - Navigation Closures

    @ObservationIgnored public var onShowDetail: ((FeaturedItem) -> Void)?
    @ObservationIgnored public var onShowProfile: (() -> Void)?

    // MARK: - DI

    @ObservationIgnored public let serviceLocator: ServiceLocator
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
    public private(set) var favoriteIds: Set<String> = []
    public var hasError: Bool = false

    // MARK: - Private Properties

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var hasLoadedInitialData: Bool = false

    // MARK: - Initialization

    public init(
        onShowDetail: ((FeaturedItem) -> Void)? = nil,
        onShowProfile: (() -> Void)? = nil,
        serviceLocator: ServiceLocator
    ) {
        self.onShowDetail = onShowDetail
        self.onShowProfile = onShowProfile
        self.serviceLocator = serviceLocator

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
        // CurrentValueSubject replays current value on subscribe — no manual init needed
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
            let message = AppError.networkError.errorDescription ?? L10n.Error.unknownError
            toastService.showToast(message: message, type: .error)
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
