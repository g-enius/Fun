//
//  Tab1ViewModel.swift
//  ViewModel
//
//  ViewModel for Tab1 (Home) screen
//

import UIKit
import Combine
import FunModel
import FunToolbox

@MainActor
public class Tab1ViewModel: ObservableObject {

    // MARK: - Coordinator

    private weak var coordinator: Tab1Coordinator?
    private weak var tabBarViewModel: HomeTabBarViewModel?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService

    /// Direct access to feature toggle service for reading current state
    private var featureToggleService: FeatureToggleServiceProtocol {
        ServiceLocator.shared.resolve(for: .featureToggles)
    }

    // MARK: - Published State

    @Published public var featuredItems: [[FeaturedItem]] = []
    @Published public var currentCarouselIndex: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var isRefreshing: Bool = false
    @Published public var isCarouselEnabled: Bool = true

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var hasLoadedInitialData: Bool = false
    nonisolated(unsafe) private var featureToggleObserver: NSObjectProtocol?
    nonisolated(unsafe) private var backgroundObserver: NSObjectProtocol?
    nonisolated(unsafe) private var foregroundObserver: NSObjectProtocol?
    private var carouselTimerCancellable: AnyCancellable?

    // MARK: - Initialization

    public init(coordinator: Tab1Coordinator?, tabBarViewModel: HomeTabBarViewModel?) {
        self.coordinator = coordinator
        self.tabBarViewModel = tabBarViewModel

        // Load initial carousel state from feature toggle
        isCarouselEnabled = featureToggleService.featuredCarousel

        startCarouselTimer()
        observeFeatureToggleChanges()
        observeSceneLifecycle()

        // Load data asynchronously on init
        Task {
            await loadFeaturedItems()
        }
    }

    deinit {
        if let observer = featureToggleObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Feature Toggle Observation

    private func observeFeatureToggleChanges() {
        featureToggleObserver = NotificationCenter.default.addObserver(
            forName: .featureTogglesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshFeatureToggles()
            }
        }
    }

    // MARK: - Scene Lifecycle

    private func observeSceneLifecycle() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pauseCarouselTimer()
            }
        }

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.resumeCarouselTimer()
            }
        }
    }

    private func pauseCarouselTimer() {
        carouselTimerCancellable?.cancel()
        carouselTimerCancellable = nil
    }

    private func resumeCarouselTimer() {
        guard carouselTimerCancellable == nil else { return }
        startCarouselTimer()
    }

    private func refreshFeatureToggles() {
        let newValue = featureToggleService.featuredCarousel
        if isCarouselEnabled != newValue {
            isCarouselEnabled = newValue
            logger.log("Carousel visibility changed to: \(newValue)")
        }
    }

    // MARK: - Data Loading

    /// Load featured items with simulated network delay
    public func loadFeaturedItems() async {
        // Show loading only for initial load
        if !hasLoadedInitialData {
            isLoading = true
        }

        logger.log("Loading featured items...")

        // Simulate network delay (500ms - 1.5s)
        let delay = UInt64.random(in: 500_000_000...1_500_000_000)
        try? await Task.sleep(nanoseconds: delay)

        // Mock data - in real app this would come from network
        let mockData: [[FeaturedItem]] = [
            [
                FeaturedItem(id: "1", title: "Async/Await", subtitle: "Modern concurrency", color: "green"),
                FeaturedItem(id: "2", title: "Combine", subtitle: "Reactive programming", color: "orange")
            ],
            [
                FeaturedItem(id: "3", title: "SwiftUI", subtitle: "Declarative UI", color: "blue"),
                FeaturedItem(id: "4", title: "Coordinator", subtitle: "Navigation pattern", color: "purple")
            ]
        ]

        featuredItems = mockData
        isLoading = false
        isRefreshing = false
        hasLoadedInitialData = true

        logger.log("Featured items loaded: \(mockData.flatMap { $0 }.count) items")
    }

    /// Pull-to-refresh handler
    public func refresh() async {
        isRefreshing = true
        logger.log("Pull to refresh triggered")

        // Simulate network delay
        let delay = UInt64.random(in: 800_000_000...1_200_000_000)
        try? await Task.sleep(nanoseconds: delay)

        // Reload data (could fetch new data from server)
        await loadFeaturedItems()
    }

    private func startCarouselTimer() {
        carouselTimerCancellable = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.rotateCarousel()
            }
    }

    private func rotateCarousel() {
        guard !featuredItems.isEmpty else { return }
        currentCarouselIndex = (currentCarouselIndex + 1) % featuredItems.count
    }

    // MARK: - Actions

    public func didTapFeaturedItem(_ item: FeaturedItem) {
        logger.log("Featured item tapped: \(item.title)")
        coordinator?.showDetail(for: item.title)
    }

    public func didTapSettings() {
        logger.log("Settings tapped")
        coordinator?.showSettings()
    }

    public func didTapProfile() {
        logger.log("Profile tapped")
        coordinator?.showProfile()
    }

    public func didTapSwitchToTab2() {
        tabBarViewModel?.switchToTab(1)
    }
}
