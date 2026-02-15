//
//  SettingsView.swift
//  UI
//
//  SwiftUI view for Settings screen
//

import SwiftUI

import FunCore
import FunModel
import FunViewModel

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section(header: Text(L10n.Settings.appearance)) {
                Picker(L10n.Settings.appearance, selection: $viewModel.appearanceMode) {
                    Text(L10n.Settings.appearanceSystem).tag(AppearanceMode.system)
                    Text(L10n.Settings.appearanceLight).tag(AppearanceMode.light)
                    Text(L10n.Settings.appearanceDark).tag(AppearanceMode.dark)
                }
                .accessibilityIdentifier(AccessibilityID.Settings.appearancePicker)
            }

            Section(header: Text(L10n.Settings.featureToggles)) {
                Toggle(L10n.Settings.featuredCarousel, isOn: $viewModel.featuredCarouselEnabled)
                    .accessibilityHint("Shows or hides the featured carousel on the home screen")
                    .accessibilityIdentifier(AccessibilityID.Settings.carouselToggle)
                Toggle(L10n.Settings.simulateErrors, isOn: $viewModel.simulateErrorsEnabled)
                    .accessibilityHint("Simulates network errors for testing purposes")
                    .accessibilityIdentifier(AccessibilityID.Settings.simulateErrorsToggle)
                Toggle(L10n.Settings.aiSummary, isOn: $viewModel.aiSummaryEnabled)
                    .accessibilityHint("Enables AI-powered summary generation on detail screens")
                    .accessibilityIdentifier(AccessibilityID.Settings.aiSummaryToggle)
            }

            Section {
                Button(L10n.Settings.resetAppearance) {
                    viewModel.resetAppearance()
                }
                .foregroundColor(.red)
                .accessibilityIdentifier(AccessibilityID.Settings.resetAppearanceButton)

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
