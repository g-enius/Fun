//
//  AccessibilityID.swift
//  UI
//
//  Centralized accessibility identifiers for UI testing
//

public enum AccessibilityID {

    public enum Login {
        public static let loginView = "login_view"
        public static let loginButton = "login_button"
    }

    public enum Home {
        public static let carousel = "home_carousel"
        public static let profileButton = "home_profile_button"
    }

    public enum Items {
        public static let searchField = "items_search_field"
        public static let categoryPicker = "items_category_picker"
        public static let itemsList = "items_list"
    }

    public enum Settings {
        public static let settingsList = "settings_list"
        public static let darkModeToggle = "settings_dark_mode_toggle"
        public static let carouselToggle = "settings_carousel_toggle"
        public static let simulateErrorsToggle = "settings_simulate_errors_toggle"
        public static let resetDarkModeButton = "settings_reset_dark_mode"
        public static let resetTogglesButton = "settings_reset_toggles"
    }

    public enum Toast {
        public static let closeButton = "toast_close_button"
    }

    public enum Detail {
        public static let shareButton = "detail_share_button"
        public static let favoriteButton = "detail_favorite_button"
    }

    public enum Profile {
        public static let dismissButton = "profile_dismiss_button"
        public static let signOutButton = "profile_sign_out_button"
        public static let searchItemsButton = "profile_search_items_button"
    }

    public enum Error {
        public static let errorStateView = "error_state_view"
        public static let retryButton = "retry_button"
        public static let itemsErrorStateView = "items_error_state_view"
    }
}
