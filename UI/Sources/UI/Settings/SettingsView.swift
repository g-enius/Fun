//
//  SettingsView.swift
//  UI
//
//  SwiftUI view for Settings screen
//

import SwiftUI

import FunCore
import FunViewModel

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section(header: Text(L10n.Settings.appearance)) {
                Toggle(L10n.Settings.darkMode, isOn: $viewModel.isDarkModeEnabled)
                    .accessibilityHint("Toggles dark mode appearance for the app")
                    .accessibilityIdentifier(AccessibilityID.Settings.darkModeToggle)
            }

            Section(header: Text(L10n.Settings.featureToggles)) {
                Toggle(L10n.Settings.featuredCarousel, isOn: $viewModel.featuredCarouselEnabled)
                    .accessibilityHint("Shows or hides the featured carousel on the home screen")
                    .accessibilityIdentifier(AccessibilityID.Settings.carouselToggle)
                Toggle(L10n.Settings.simulateErrors, isOn: $viewModel.simulateErrorsEnabled)
                    .accessibilityHint("Simulates network errors for testing purposes")
                    .accessibilityIdentifier(AccessibilityID.Settings.simulateErrorsToggle)
            }

            Section {
                Button(L10n.Settings.resetDarkMode) {
                    viewModel.resetDarkMode()
                }
                .foregroundColor(.red)
                .accessibilityIdentifier(AccessibilityID.Settings.resetDarkModeButton)

                Button(L10n.Settings.resetFeatureToggles) {
                    viewModel.resetFeatureToggles()
                }
                .foregroundColor(.red)
                .accessibilityIdentifier(AccessibilityID.Settings.resetTogglesButton)
            }

            Section(header: Text(L10n.Settings.systemInfo)) {
                HStack {
                    Text(L10n.Common.version)
                    Spacer()
                    Text(Bundle.main.appVersion)
                        .foregroundColor(.gray)
                }
                HStack {
                    Text(L10n.Common.build)
                    Spacer()
                    Text(Bundle.main.buildNumber)
                        .foregroundColor(.gray)
                }
            }

        }
        .accessibilityIdentifier(AccessibilityID.Settings.settingsList)
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(viewModel: PreviewHelper.makeSettingsViewModel())
                .navigationTitle("Settings")
        }
    }
}
