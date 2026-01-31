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
        NavigationView {
            Form {
                Section {
                    Toggle("Notifications", isOn: $viewModel.notificationsEnabled)
                    Toggle("Privacy Mode", isOn: $viewModel.privacyModeEnabled)
                }

                Section {
                    Button("About") {
                        viewModel.didTapAbout()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.didTapDismiss()
                    }
                }
            }
        }
    }
}
