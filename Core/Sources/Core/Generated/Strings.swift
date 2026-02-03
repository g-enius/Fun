// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum Accessibility {
    /// Double tap to view details
    public static let doubleTapToViewDetails = L10n.tr("Localizable", "accessibility.doubleTapToViewDetails", fallback: "Double tap to view details")
  }
  public enum Common {
    /// Build
    public static let build = L10n.tr("Localizable", "common.build", fallback: "Build")
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Close
    public static let close = L10n.tr("Localizable", "common.close", fallback: "Close")
    /// Done
    public static let done = L10n.tr("Localizable", "common.done", fallback: "Done")
    /// Localizable.strings
    ///   UI
    /// 
    ///   English localization strings
    public static let loading = L10n.tr("Localizable", "common.loading", fallback: "Loading...")
    /// Share
    public static let share = L10n.tr("Localizable", "common.share", fallback: "Share")
    /// Version
    public static let version = L10n.tr("Localizable", "common.version", fallback: "Version")
  }
  public enum Detail {
    /// Add to Favorites
    public static let addToFavorites = L10n.tr("Localizable", "detail.addToFavorites", fallback: "Add to Favorites")
    /// Description
    public static let description = L10n.tr("Localizable", "detail.description", fallback: "Description")
    /// How it's used in this demo
    public static let howUsed = L10n.tr("Localizable", "detail.howUsed", fallback: "How it's used in this demo")
    /// This is a detailed description of %@. It showcases the coordinator pattern for navigation in iOS apps.
    public static func itemDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "detail.itemDescription", String(describing: p1), fallback: "This is a detailed description of %@. It showcases the coordinator pattern for navigation in iOS apps.")
    }
    /// Just now
    public static let justNow = L10n.tr("Localizable", "detail.justNow", fallback: "Just now")
    /// Push Navigation
    public static let pushNavigation = L10n.tr("Localizable", "detail.pushNavigation", fallback: "Push Navigation")
    /// Remove from Favorites
    public static let removeFromFavorites = L10n.tr("Localizable", "detail.removeFromFavorites", fallback: "Remove from Favorites")
    /// Check out %@!
    public static func shareText(_ p1: Any) -> String {
      return L10n.tr("Localizable", "detail.shareText", String(describing: p1), fallback: "Check out %@!")
    }
    /// Using Coordinator Pattern
    public static let usingCoordinatorPattern = L10n.tr("Localizable", "detail.usingCoordinatorPattern", fallback: "Using Coordinator Pattern")
  }
  public enum Error {
    /// Failed to load content
    public static let failedToLoad = L10n.tr("Localizable", "error.failedToLoad", fallback: "Failed to load content")
    /// Network connection failed. Please check your internet and try again.
    public static let networkError = L10n.tr("Localizable", "error.networkError", fallback: "Network connection failed. Please check your internet and try again.")
    /// Retry
    public static let retry = L10n.tr("Localizable", "error.retry", fallback: "Retry")
    /// Server error occurred. Please try again later.
    public static let serverError = L10n.tr("Localizable", "error.serverError", fallback: "Server error occurred. Please try again later.")
    /// Something went wrong. Please try again.
    public static let unknownError = L10n.tr("Localizable", "error.unknownError", fallback: "Something went wrong. Please try again.")
  }
  public enum Home {
    /// Carousel Disabled
    public static let carouselDisabled = L10n.tr("Localizable", "home.carouselDisabled", fallback: "Carousel Disabled")
    /// Enable the Featured Carousel from the Settings tab to see featured items here.
    public static let enableFromSettings = L10n.tr("Localizable", "home.enableFromSettings", fallback: "Enable the Featured Carousel from the Settings tab to see featured items here.")
    /// Featured
    public static let featured = L10n.tr("Localizable", "home.featured", fallback: "Featured")
  }
  public enum Items {
    /// All
    public static let categoryAll = L10n.tr("Localizable", "items.categoryAll", fallback: "All")
    /// Favorite
    public static let favorite = L10n.tr("Localizable", "items.favorite", fallback: "Favorite")
    /// Loaded Items
    public static let loadedItems = L10n.tr("Localizable", "items.loadedItems", fallback: "Loaded Items")
    /// Unfavorite
    public static let unfavorite = L10n.tr("Localizable", "items.unfavorite", fallback: "Unfavorite")
  }
  public enum Profile {
    /// Days
    public static let days = L10n.tr("Localizable", "profile.days", fallback: "Days")
    /// Favorites
    public static let favorites = L10n.tr("Localizable", "profile.favorites", fallback: "Favorites")
    /// Search for Items?
    public static let searchItems = L10n.tr("Localizable", "profile.searchItems", fallback: "Search for Items?")
    /// Profile
    public static let title = L10n.tr("Localizable", "profile.title", fallback: "Profile")
    /// Views
    public static let views = L10n.tr("Localizable", "profile.views", fallback: "Views")
  }
  public enum Search {
    /// Keep Typing...
    public static let keepTyping = L10n.tr("Localizable", "search.keepTyping", fallback: "Keep Typing...")
    /// Search (min %d chars)...
    public static func minCharacters(_ p1: Int) -> String {
      return L10n.tr("Localizable", "search.minCharacters", p1, fallback: "Search (min %d chars)...")
    }
    /// No Results
    public static let noResults = L10n.tr("Localizable", "search.noResults", fallback: "No Results")
    /// Searching...
    public static let searching = L10n.tr("Localizable", "search.searching", fallback: "Searching...")
    /// Try a different search term or category
    public static let tryDifferentTerm = L10n.tr("Localizable", "search.tryDifferentTerm", fallback: "Try a different search term or category")
    /// Type at least %d characters to search
    public static func typeMinCharacters(_ p1: Int) -> String {
      return L10n.tr("Localizable", "search.typeMinCharacters", p1, fallback: "Type at least %d characters to search")
    }
  }
  public enum Settings {
    /// About
    public static let about = L10n.tr("Localizable", "settings.about", fallback: "About")
    /// Analytics
    public static let analytics = L10n.tr("Localizable", "settings.analytics", fallback: "Analytics")
    /// Appearance
    public static let appearance = L10n.tr("Localizable", "settings.appearance", fallback: "Appearance")
    /// Dark Mode
    public static let darkMode = L10n.tr("Localizable", "settings.darkMode", fallback: "Dark Mode")
    /// Debug Mode
    public static let debugMode = L10n.tr("Localizable", "settings.debugMode", fallback: "Debug Mode")
    /// Featured Carousel
    public static let featuredCarousel = L10n.tr("Localizable", "settings.featuredCarousel", fallback: "Featured Carousel")
    /// Feature Toggles
    public static let featureToggles = L10n.tr("Localizable", "settings.featureToggles", fallback: "Feature Toggles")
    /// Notifications
    public static let notifications = L10n.tr("Localizable", "settings.notifications", fallback: "Notifications")
    /// Privacy Mode
    public static let privacyMode = L10n.tr("Localizable", "settings.privacyMode", fallback: "Privacy Mode")
    /// Reset Dark Mode
    public static let resetDarkMode = L10n.tr("Localizable", "settings.resetDarkMode", fallback: "Reset Dark Mode")
    /// Reset Feature Toggles
    public static let resetFeatureToggles = L10n.tr("Localizable", "settings.resetFeatureToggles", fallback: "Reset Feature Toggles")
    /// Simulate Errors
    public static let simulateErrors = L10n.tr("Localizable", "settings.simulateErrors", fallback: "Simulate Errors")
    /// System Information
    public static let systemInfo = L10n.tr("Localizable", "settings.systemInfo", fallback: "System Information")
  }
  public enum Tabs {
    /// Home
    public static let home = L10n.tr("Localizable", "tabs.home", fallback: "Home")
    /// Items
    public static let items = L10n.tr("Localizable", "tabs.items", fallback: "Items")
    /// Search
    public static let search = L10n.tr("Localizable", "tabs.search", fallback: "Search")
    /// Settings
    public static let settings = L10n.tr("Localizable", "tabs.settings", fallback: "Settings")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
