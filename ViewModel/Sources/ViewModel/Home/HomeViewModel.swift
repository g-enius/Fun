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

    // MARK: - Navigation Closures

    public var onShowDetail: ((FeaturedItem) -> Void)?
    public var onShowProfile: (() -> Void)?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService
    @Service(.network) private var networkService: NetworkServiceProtocol
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

    public init(
        onShowDetail: ((FeaturedItem) -> Void)? = nil,
        onShowProfile: (() -> Void)? = nil
    ) {
        self.onShowDetail = onShowDetail
        self.onShowProfile = onShowProfile

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
            // SwiftUI's .refreshable cancels the task when user releases drag early —
            // swallow cancellation to keep refresh smooth
            featuredItems = []
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
