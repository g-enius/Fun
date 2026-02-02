//
//  Tab5View.swift
//  UI
//
//  SwiftUI view for Tab5 (Settings) screen
//

import SwiftUI
import FunViewModel
import FunModel

public struct Tab5View: View {
    @ObservedObject var viewModel: Tab5ViewModel

    public init(viewModel: Tab5ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section(header: Text(L10n.Settings.appearance)) {
                Toggle(L10n.Settings.darkMode, isOn: $viewModel.isDarkModeEnabled)
                    .accessibilityIdentifier(AccessibilityID.Tab5.darkModeToggle)
            }

            Section(header: Text(L10n.Settings.featureToggles)) {
                Toggle(L10n.Settings.featuredCarousel, isOn: $viewModel.featuredCarouselEnabled)
                    .accessibilityIdentifier("toggle_carousel")
                Toggle(L10n.Settings.analytics, isOn: $viewModel.analyticsEnabled)
                    .accessibilityIdentifier("toggle_analytics")
                Toggle(L10n.Settings.debugMode, isOn: $viewModel.debugModeEnabled)
                    .accessibilityIdentifier("toggle_debug")
            }

            Section {
                Button(L10n.Settings.resetDarkMode) {
                    viewModel.resetDarkMode()
                }
                .foregroundColor(.red)

                Button(L10n.Settings.resetFeatureToggles) {
                    viewModel.resetFeatureToggles()
                }
                .foregroundColor(.red)
            }

            Section(header: Text(L10n.Settings.systemInfo)) {
                HStack {
                    Text(L10n.Common.version)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text(L10n.Common.build)
                    Spacer()
                    Text("42")
                        .foregroundColor(.gray)
                }
            }
        }
        .accessibilityIdentifier(AccessibilityID.Tab5.settingsList)
    }
}
