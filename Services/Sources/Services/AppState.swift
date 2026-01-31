import Foundation
import FunModel
import Combine

@MainActor
public final class AppState: ObservableObject {
    public static let shared = AppState()

    @Published public var settings: AppSettings
    @Published public var favoriteItemIds: Set<String>
    @Published public var currentCarouselIndex: Int = 0

    private var carouselTimer: Timer?

    private init() {
        self.settings = .default
        self.favoriteItemIds = ["item1"] // Item 1 is favorited by default
        startCarouselTimer()
    }

    // MARK: - Settings
    public func toggleDarkMode() {
        settings.isDarkMode.toggle()
        NotificationCenter.default.post(name: .appSettingsDidChange, object: nil)
    }

    public func toggleProfileScreen() {
        settings.isProfileScreenEnabled.toggle()
    }

    public func toggleToastNotifications() {
        settings.isToastNotificationsEnabled.toggle()
    }

    public func toggleFeaturedCarousel() {
        settings.isFeaturedCarouselEnabled.toggle()
    }

    public func resetDarkMode() {
        settings.isDarkMode = false
        NotificationCenter.default.post(name: .appSettingsDidChange, object: nil)
    }

    public func resetFeatureToggles() {
        settings.isProfileScreenEnabled = true
        settings.isToastNotificationsEnabled = true
        settings.isFeaturedCarouselEnabled = true
    }

    // MARK: - Favorites
    public func isFavorite(_ itemId: String) -> Bool {
        favoriteItemIds.contains(itemId)
    }

    public func toggleFavorite(_ itemId: String) {
        if favoriteItemIds.contains(itemId) {
            favoriteItemIds.remove(itemId)
        } else {
            favoriteItemIds.insert(itemId)
        }
    }

    public func addToFavorites(_ itemId: String) {
        favoriteItemIds.insert(itemId)
    }

    public func removeFromFavorites(_ itemId: String) {
        favoriteItemIds.remove(itemId)
    }

    // MARK: - Carousel
    private func startCarouselTimer() {
        carouselTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceCarousel()
            }
        }
    }

    public func advanceCarousel() {
        let totalSets = FeaturedItem.allCarouselSets.count
        currentCarouselIndex = (currentCarouselIndex + 1) % totalSets
    }

    public var currentFeaturedItems: [FeaturedItem] {
        FeaturedItem.allCarouselSets[currentCarouselIndex]
    }
}

public extension Notification.Name {
    static let appSettingsDidChange = Notification.Name("appSettingsDidChange")
}
