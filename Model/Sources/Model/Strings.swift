//
//  Strings.swift
//  Model
//
//  Centralized localized strings for the app
//

import Foundation

public enum L10n {

    // MARK: - Common

    public enum Common {
        public static let loading = String(localized: "common.loading", defaultValue: "Loading...")
        public static let cancel = String(localized: "common.cancel", defaultValue: "Cancel")
        public static let done = String(localized: "common.done", defaultValue: "Done")
        public static let share = String(localized: "common.share", defaultValue: "Share")
        public static let version = String(localized: "common.version", defaultValue: "Version")
        public static let build = String(localized: "common.build", defaultValue: "Build")
    }

    // MARK: - Tabs

    public enum Tabs {
        public static let home = String(localized: "tabs.home", defaultValue: "Home")
        public static let search = String(localized: "tabs.search", defaultValue: "Search")
        public static let items = String(localized: "tabs.items", defaultValue: "Items")
        public static let settings = String(localized: "tabs.settings", defaultValue: "Settings")
    }

    // MARK: - Home (Tab1)

    public enum Home {
        public static let featured = String(localized: "home.featured", defaultValue: "Featured")
        public static let switchToTab2 = String(localized: "home.switchToTab2", defaultValue: "Switch to Tab 2")
    }

    // MARK: - Search (Tab2)

    public enum Search {
        public static let noResults = String(localized: "search.noResults", defaultValue: "No Results")
        public static let searching = String(localized: "search.searching", defaultValue: "Searching...")
        public static func minCharacters(_ count: Int) -> String {
            String(format: NSLocalizedString("search.minCharacters", value: "Search (min %d chars)...", comment: ""), count)
        }
        public static func typeMinCharacters(_ count: Int) -> String {
            String(format: NSLocalizedString("search.typeMinCharacters", value: "Type at least %d characters to search", comment: ""), count)
        }
        public static let tryDifferentTerm = String(localized: "search.tryDifferentTerm", defaultValue: "Try a different search term or category")
    }

    // MARK: - Items (Tab3)

    public enum Items {
        public static let loadedItems = String(localized: "items.loadedItems", defaultValue: "Loaded Items")
        public static let favorite = String(localized: "items.favorite", defaultValue: "Favorite")
        public static let unfavorite = String(localized: "items.unfavorite", defaultValue: "Unfavorite")
    }

    // MARK: - Settings (Tab5)

    public enum Settings {
        public static let appearance = String(localized: "settings.appearance", defaultValue: "Appearance")
        public static let darkMode = String(localized: "settings.darkMode", defaultValue: "Dark Mode")
        public static let featureToggles = String(localized: "settings.featureToggles", defaultValue: "Feature Toggles")
        public static let featuredCarousel = String(localized: "settings.featuredCarousel", defaultValue: "Featured Carousel")
        public static let analytics = String(localized: "settings.analytics", defaultValue: "Analytics")
        public static let debugMode = String(localized: "settings.debugMode", defaultValue: "Debug Mode")
        public static let resetDarkMode = String(localized: "settings.resetDarkMode", defaultValue: "Reset Dark Mode")
        public static let resetFeatureToggles = String(localized: "settings.resetFeatureToggles", defaultValue: "Reset Feature Toggles")
        public static let systemInfo = String(localized: "settings.systemInfo", defaultValue: "System Information")
        public static let notifications = String(localized: "settings.notifications", defaultValue: "Notifications")
        public static let privacyMode = String(localized: "settings.privacyMode", defaultValue: "Privacy Mode")
        public static let about = String(localized: "settings.about", defaultValue: "About")
    }

    // MARK: - Detail

    public enum Detail {
        public static let description = String(localized: "detail.description", defaultValue: "Description")
        public static let justNow = String(localized: "detail.justNow", defaultValue: "Just now")
        public static let addToFavorites = String(localized: "detail.addToFavorites", defaultValue: "Add to Favorites")
        public static let removeFromFavorites = String(localized: "detail.removeFromFavorites", defaultValue: "Remove from Favorites")
        public static let pushNavigation = String(localized: "detail.pushNavigation", defaultValue: "Push Navigation")
        public static let usingCoordinatorPattern = String(localized: "detail.usingCoordinatorPattern", defaultValue: "Using Coordinator Pattern")
        public static func itemDescription(_ title: String) -> String {
            String(format: NSLocalizedString("detail.itemDescription", value: "This is a detailed description of %@. It showcases the coordinator pattern for navigation in iOS apps.", comment: ""), title)
        }
    }

    // MARK: - Profile

    public enum Profile {
        public static let title = String(localized: "profile.title", defaultValue: "Profile")
        public static let editProfile = String(localized: "profile.editProfile", defaultValue: "Edit Profile")
        public static let views = String(localized: "profile.views", defaultValue: "Views")
        public static let favorites = String(localized: "profile.favorites", defaultValue: "Favorites")
        public static let days = String(localized: "profile.days", defaultValue: "Days")
    }
}
