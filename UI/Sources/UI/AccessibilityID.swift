//
//  AccessibilityID.swift
//  UI
//
//  Centralized accessibility identifiers for UI testing
//

import Foundation

public enum AccessibilityID {

    public enum Tab1 {
        public static let carousel = "tab1_carousel"
        public static let settingsButton = "tab1_settings_button"
        public static let switchTabButton = "tab1_switch_tab_button"
        public static let profileButton = "tab1_profile_button"
    }

    public enum Tab2 {
        public static let searchField = "tab2_search_field"
        public static let categoryPicker = "tab2_category_picker"
        public static let resultsList = "tab2_results_list"
    }

    public enum Tab3 {
        public static let itemsList = "tab3_items_list"
    }

    public enum Tab4 {
        public static let featureTogglesList = "tab4_feature_toggles_list"
    }

    public enum Tab5 {
        public static let settingsList = "tab5_settings_list"
        public static let darkModeToggle = "tab5_dark_mode_toggle"
    }

    public enum Detail {
        public static let shareButton = "detail_share_button"
        public static let favoriteButton = "detail_favorite_button"
    }

    public enum Profile {
        public static let dismissButton = "profile_dismiss_button"
    }

    public enum Settings {
        public static let dismissButton = "settings_dismiss_button"
    }
}
