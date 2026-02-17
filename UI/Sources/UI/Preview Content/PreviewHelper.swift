//
//  PreviewHelper.swift
//  UI
//
//  Helper utilities for SwiftUI previews
//

import Combine
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
        locator.register(PreviewNetworkService() as NetworkService, for: .network)
        locator.register(PreviewToastService() as ToastServiceProtocol, for: .toast)
        locator.register(PreviewAIService() as AIServiceProtocol, for: .ai)

        isConfigured = true
    }

    /// Creates a HomeViewModel configured for previews
    public static func makeHomeViewModel() -> HomeViewModel {
        configureMockServices()
        return HomeViewModel(coordinator: nil)
    }

    /// Creates an ItemsViewModel configured for previews
    public static func makeItemsViewModel() -> ItemsViewModel {
        configureMockServices()
        return ItemsViewModel(coordinator: nil)
    }

    /// Creates a SettingsViewModel configured for previews
    public static func makeSettingsViewModel() -> SettingsViewModel {
        configureMockServices()
        return SettingsViewModel(coordinator: nil)
    }

    /// Creates a ProfileViewModel configured for previews
    public static func makeProfileViewModel() -> ProfileViewModel {
        configureMockServices()
        return ProfileViewModel(coordinator: nil)
    }

    /// Creates a DetailViewModel configured for previews
    public static func makeDetailViewModel() -> DetailViewModel {
        configureMockServices()
        return DetailViewModel(item: .asyncAwait, coordinator: nil)
    }

    /// Creates a LoginViewModel configured for previews
    public static func makeLoginViewModel() -> LoginViewModel {
        configureMockServices()
        return LoginViewModel(coordinator: nil)
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
    private let subject: CurrentValueSubject<Set<String>, Never>
    var favoritesDidChange: AnyPublisher<Set<String>, Never> { subject.eraseToAnyPublisher() }

    init(initialFavorites: Set<String> = []) {
        self.favorites = initialFavorites
        self.subject = CurrentValueSubject(initialFavorites)
    }
    func isFavorited(_ itemId: String) -> Bool { favorites.contains(itemId) }
    func toggleFavorite(_ itemId: String) {
        if favorites.contains(itemId) { favorites.remove(itemId) } else { favorites.insert(itemId) }
        subject.send(favorites)
    }
    func addFavorite(_ itemId: String) { favorites.insert(itemId); subject.send(favorites) }
    func removeFavorite(_ itemId: String) { favorites.remove(itemId); subject.send(favorites) }
    func resetFavorites() { favorites.removeAll(); subject.send(favorites) }
}

@MainActor
private final class PreviewFeatureToggleService: FeatureToggleServiceProtocol {
    @Published var featuredCarousel: Bool = true
    @Published var simulateErrors: Bool = false
    @Published var aiSummary: Bool = true
    @Published var appearanceMode: AppearanceMode = .system
    var featuredCarouselPublisher: AnyPublisher<Bool, Never> { $featuredCarousel.eraseToAnyPublisher() }
    var simulateErrorsPublisher: AnyPublisher<Bool, Never> { $simulateErrors.eraseToAnyPublisher() }
    var aiSummaryPublisher: AnyPublisher<Bool, Never> { $aiSummary.eraseToAnyPublisher() }
    var appearanceModePublisher: AnyPublisher<AppearanceMode, Never> { $appearanceMode.eraseToAnyPublisher() }
}

@MainActor
private final class PreviewAIService: AIServiceProtocol {
    var isAvailable: Bool { true }
    func summarize(_ text: String) async throws -> String {
        "This is a preview summary of the technology feature."
    }
}

@MainActor
private final class PreviewNetworkService: NetworkService {
    func login() async throws {}
    func fetchFeaturedItems() async throws -> [[FeaturedItem]] { FeaturedItem.allCarouselSets }
    func fetchAllItems() async throws -> [FeaturedItem] { FeaturedItem.all }
}

@MainActor
private final class PreviewToastService: ToastServiceProtocol {
    private let subject = PassthroughSubject<ToastEvent, Never>()
    var toastPublisher: AnyPublisher<ToastEvent, Never> { subject.eraseToAnyPublisher() }
    func showToast(message: String, type: ToastType) { subject.send(ToastEvent(message: message, type: type)) }
}
