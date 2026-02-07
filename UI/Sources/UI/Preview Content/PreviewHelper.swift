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

        // Register mock services
        locator.register(PreviewLoggerService() as LoggerService, for: .logger)
        let favorites = MockFavoritesService(initialFavorites: ["asyncawait", "swiftui"])
        locator.register(favorites as FavoritesServiceProtocol, for: .favorites)

        let toggles = MockFeatureToggleService(featuredCarousel: true, simulateErrors: false)
        locator.register(toggles as FeatureToggleServiceProtocol, for: .featureToggles)
        locator.register(MockToastService() as ToastServiceProtocol, for: .toast)

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

// MARK: - Preview Logger Service

/// Minimal logger for previews - does nothing
@MainActor
private final class PreviewLoggerService: LoggerService {
    func log(_ message: String) {}
    func log(_ message: String, level: LogLevel) {}
    func log(_ message: String, level: LogLevel, category: LogCategory) {}
    func log(_ message: String, level: LogLevel, category: String) {}
}
