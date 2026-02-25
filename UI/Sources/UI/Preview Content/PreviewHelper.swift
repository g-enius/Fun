//
//  PreviewHelper.swift
//  UI
//
//  Helper utilities for SwiftUI previews
//

import SwiftUI

import FunCore
import FunModel
import FunViewModel

/// Sets up mock services in ServiceLocator for SwiftUI previews
@MainActor
public enum PreviewHelper {

    private static var isConfigured = false

    /// Call this once at the start of preview to register mock services
    public static func configureMockServices() {
        guard !isConfigured else { return }

        let locator = ServiceLocator.shared

        // Register preview stub services
        locator.register(PreviewLoggerService() as LoggerService, for: .logger)
        let favorites = PreviewFavoritesService(initialFavorites: ["asyncawait", "swiftui"])
        locator.register(favorites as FavoritesServiceProtocol, for: .favorites)

        let toggles = PreviewFeatureToggleService()
        locator.register(toggles as FeatureToggleServiceProtocol, for: .featureToggles)
        locator.register(PreviewNetworkService() as NetworkServiceProtocol, for: .network)
        locator.register(PreviewToastService() as ToastServiceProtocol, for: .toast)
        locator.register(PreviewAIService() as AIServiceProtocol, for: .ai)

        isConfigured = true
    }

    /// Creates a HomeViewModel configured for previews
    public static func makeHomeViewModel() -> HomeViewModel {
        configureMockServices()
        return HomeViewModel()
    }

    /// Creates an ItemsViewModel configured for previews
    public static func makeItemsViewModel() -> ItemsViewModel {
        configureMockServices()
        return ItemsViewModel()
    }

    /// Creates a SettingsViewModel configured for previews
    public static func makeSettingsViewModel() -> SettingsViewModel {
        configureMockServices()
        return SettingsViewModel()
    }

    /// Creates a ProfileViewModel configured for previews
    public static func makeProfileViewModel() -> ProfileViewModel {
        configureMockServices()
        return ProfileViewModel()
    }

    /// Creates a DetailViewModel configured for previews
    public static func makeDetailViewModel() -> DetailViewModel {
        configureMockServices()
        return DetailViewModel(item: .asyncAwait)
    }

    /// Creates a LoginViewModel configured for previews
    public static func makeLoginViewModel() -> LoginViewModel {
        configureMockServices()
        return LoginViewModel()
    }
}

// MARK: - Preview Stub Services

@MainActor
private final class PreviewLoggerService: LoggerService {
    func log(_ message: String) {}
    func log(_ message: String, level: LogLevel) {}
    func log(_ message: String, level: LogLevel, category: LogCategory) {}
    func log(_ message: String, level: LogLevel, category: String) {}
}

@MainActor
private final class PreviewFavoritesService: FavoritesServiceProtocol {
    var favorites: Set<String>
    private let broadcaster = StreamBroadcaster<Set<String>>()
    var favoritesChanges: AsyncStream<Set<String>> { broadcaster.makeStream() }

    init(initialFavorites: Set<String> = []) {
        self.favorites = initialFavorites
    }
    func isFavorited(_ itemId: String) -> Bool { favorites.contains(itemId) }
    func toggleFavorite(_ itemId: String) {
        if favorites.contains(itemId) { favorites.remove(itemId) } else { favorites.insert(itemId) }
        broadcaster.yield(favorites)
    }
    func addFavorite(_ itemId: String) { favorites.insert(itemId); broadcaster.yield(favorites) }
    func removeFavorite(_ itemId: String) { favorites.remove(itemId); broadcaster.yield(favorites) }
    func resetFavorites() { favorites.removeAll(); broadcaster.yield(favorites) }
}

@MainActor
private final class PreviewFeatureToggleService: FeatureToggleServiceProtocol {
    var featuredCarousel: Bool = true
    var simulateErrors: Bool = false
    var aiSummary: Bool = true
    var appearanceMode: AppearanceMode = .system

    private let carouselBroadcaster = StreamBroadcaster<Bool>()
    private let appearanceBroadcaster = StreamBroadcaster<AppearanceMode>()

    var featuredCarouselChanges: AsyncStream<Bool> { carouselBroadcaster.makeStream() }
    var appearanceModeChanges: AsyncStream<AppearanceMode> { appearanceBroadcaster.makeStream() }
}

@MainActor
private final class PreviewAIService: AIServiceProtocol {
    var isAvailable: Bool { true }
    func summarize(_ text: String) async throws -> String {
        "This is a preview summary of the technology feature."
    }
}

@MainActor
private final class PreviewNetworkService: NetworkServiceProtocol {
    func login() async throws {}
    func fetchFeaturedItems() async throws -> [[FeaturedItem]] { FeaturedItem.allCarouselSets }
    func fetchAllItems() async throws -> [FeaturedItem] { FeaturedItem.all }
    func searchItems(query: String, category: String) async throws -> [FeaturedItem] { FeaturedItem.all }
}

@MainActor
private final class PreviewToastService: ToastServiceProtocol {
    private let broadcaster = StreamBroadcaster<ToastEvent>()
    var toastEvents: AsyncStream<ToastEvent> { broadcaster.makeStream() }
    func showToast(message: String, type: ToastType) { broadcaster.yield(ToastEvent(message: message, type: type)) }
}
