//
//  Tab5View.swift
//  UI
//
//  SwiftUI view for Tab5 (Settings) screen
//

import SwiftUI
import FunViewModel

public struct Tab5View: View {
    @ObservedObject var viewModel: Tab5ViewModel

    public init(viewModel: Tab5ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $viewModel.isDarkModeEnabled)
                    .accessibilityIdentifier(AccessibilityID.Tab5.darkModeToggle)
            }

            Section(header: Text("Feature Toggles")) {
                Toggle("Featured Carousel", isOn: $viewModel.featuredCarouselEnabled)
                    .accessibilityIdentifier("toggle_carousel")
                Toggle("Analytics", isOn: $viewModel.analyticsEnabled)
                    .accessibilityIdentifier("toggle_analytics")
                Toggle("Debug Mode", isOn: $viewModel.debugModeEnabled)
                    .accessibilityIdentifier("toggle_debug")
            }

            Section {
                Button("Reset Dark Mode") {
                    viewModel.resetDarkMode()
                }
                .foregroundColor(.red)
                .accessibilityLabel("Reset dark mode to default")

                Button("Reset Feature Toggles") {
                    viewModel.resetFeatureToggles()
                }
                .foregroundColor(.red)
                .accessibilityLabel("Reset all feature toggles to defaults")
            }

            Section(header: Text("System Information")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Build")
                    Spacer()
                    Text("42")
                        .foregroundColor(.gray)
                }
            }
        }
        .accessibilityIdentifier(AccessibilityID.Tab5.settingsList)
    }
}
