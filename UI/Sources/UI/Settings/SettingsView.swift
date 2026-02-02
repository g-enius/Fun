//
//  SettingsView.swift
//  UI
//
//  SwiftUI view for Settings screen (modal)
//

import SwiftUI
import FunViewModel

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section {
                Toggle("Notifications", isOn: $viewModel.notificationsEnabled)
                    .accessibilityIdentifier("toggle_notifications")
                Toggle("Privacy Mode", isOn: $viewModel.privacyModeEnabled)
                    .accessibilityIdentifier("toggle_privacy")
            }

            Section {
                Button("About") {
                    viewModel.didTapAbout()
                }
                .accessibilityLabel("View about information")
            }
        }
    }
}
