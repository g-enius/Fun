//
//  SettingsView.swift
//  UI
//
//  SwiftUI view for Settings screen (modal)
//

import SwiftUI
import FunViewModel
import FunModel

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section {
                Toggle(L10n.Settings.notifications, isOn: $viewModel.notificationsEnabled)
                    .accessibilityIdentifier("toggle_notifications")
                Toggle(L10n.Settings.privacyMode, isOn: $viewModel.privacyModeEnabled)
                    .accessibilityIdentifier("toggle_privacy")
            }

            Section {
                Button(L10n.Settings.about) {
                    viewModel.didTapAbout()
                }
                .accessibilityLabel(L10n.Settings.about)
            }
        }
    }
}
