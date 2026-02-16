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
    /// Page %d of %d
    public static func pageIndicator(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Localizable", "accessibility.pageIndicator", p1, p2, fallback: "Page %d of %d")
    }
  }
  public enum Common {
    /// Build
    public static let build = L10n.tr("Localizable", "common.build", fallback: "Build")
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Close
    public static let close = L10n.tr("Localizable", "common.close", fallback: "Close")
    /// Localizable.strings
    ///   UI
    /// 
    ///   English localization strings
    public static let loading = L10n.tr("Localizable", "common.loading", fallback: "Loading...")
    /// Version
    public static let version = L10n.tr("Localizable", "common.version", fallback: "Version")
  }
  public enum Detail {
    /// Add to Favorites
    public static let addToFavorites = L10n.tr("Localizable", "detail.addToFavorites", fallback: "Add to Favorites")
    /// AI Summary
    public static let aiSummary = L10n.tr("Localizable", "detail.aiSummary", fallback: "AI Summary")
    /// Generate Summary
    public static let generateSummary = L10n.tr("Localizable", "detail.generateSummary", fallback: "Generate Summary")
    /// How it's used in this demo
    public static let howUsed = L10n.tr("Localizable", "detail.howUsed", fallback: "How it's used in this demo")
    /// Remove from Favorites
    public static let removeFromFavorites = L10n.tr("Localizable", "detail.removeFromFavorites", fallback: "Remove from Favorites")
    /// Check out %@!
    public static func shareText(_ p1: Any) -> String {
      return L10n.tr("Localizable", "detail.shareText", String(describing: p1), fallback: "Check out %@!")
    }
    /// Failed to generate summary
    public static let summaryFailed = L10n.tr("Localizable", "detail.summaryFailed", fallback: "Failed to generate summary")
  }
  public enum Error {
    /// Failed to load content
    public static let failedToLoad = L10n.tr("Localizable", "error.failedToLoad", fallback: "Failed to load content")
    /// Network connection failed. Please check your internet and try again.
    public static let networkError = L10n.tr("Localizable", "error.networkError", fallback: "Network connection failed. Please check your internet and try again.")
    /// Retry
    public static let retry = L10n.tr("Localizable", "error.retry", fallback: "Retry")
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
    /// Unfavorite
    public static let unfavorite = L10n.tr("Localizable", "items.unfavorite", fallback: "Unfavorite")
  }
  public enum Login {
    /// This is a demo login - no credentials required
    public static let demoNote = L10n.tr("Localizable", "login.demoNote", fallback: "This is a demo login - no credentials required")
    /// Signing In...
    public static let loggingIn = L10n.tr("Localizable", "login.loggingIn", fallback: "Signing In...")
    /// Sign In
    public static let loginButton = L10n.tr("Localizable", "login.loginButton", fallback: "Sign In")
    /// A demo app showcasing iOS architecture patterns and best practices.
    public static let subtitle = L10n.tr("Localizable", "login.subtitle", fallback: "A demo app showcasing iOS architecture patterns and best practices.")
    /// Welcome to Fun
    public static let welcome = L10n.tr("Localizable", "login.welcome", fallback: "Welcome to Fun")
  }
  public enum Profile {
    /// Days
    public static let days = L10n.tr("Localizable", "profile.days", fallback: "Days")
    /// Favorites
    public static let favorites = L10n.tr("Localizable", "profile.favorites", fallback: "Favorites")
    /// Sign Out
    public static let logout = L10n.tr("Localizable", "profile.logout", fallback: "Sign Out")
    /// Go to Items
    public static let searchItems = L10n.tr("Localizable", "profile.searchItems", fallback: "Go to Items")
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
    /// AI Summary
    public static let aiSummary = L10n.tr("Localizable", "settings.aiSummary", fallback: "AI Summary")
    /// Appearance
    public static let appearance = L10n.tr("Localizable", "settings.appearance", fallback: "Appearance")
    /// Dark
    public static let appearanceDark = L10n.tr("Localizable", "settings.appearanceDark", fallback: "Dark")
    /// Light
    public static let appearanceLight = L10n.tr("Localizable", "settings.appearanceLight", fallback: "Light")
    /// System
    public static let appearanceSystem = L10n.tr("Localizable", "settings.appearanceSystem", fallback: "System")
    /// Featured Carousel
    public static let featuredCarousel = L10n.tr("Localizable", "settings.featuredCarousel", fallback: "Featured Carousel")
    /// Feature Toggles
    public static let featureToggles = L10n.tr("Localizable", "settings.featureToggles", fallback: "Feature Toggles")
    /// Reset Appearance
    public static let resetAppearance = L10n.tr("Localizable", "settings.resetAppearance", fallback: "Reset Appearance")
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
