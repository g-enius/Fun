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
        NavigationView {
            Form {
                // Dark Mode Section
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $viewModel.isDarkModeEnabled)
                }

                // Feature Toggles Section
                Section(header: Text("Feature Toggles")) {
                    Toggle("Featured Carousel", isOn: $viewModel.featuredCarouselEnabled)
                    Toggle("Analytics", isOn: $viewModel.analyticsEnabled)
                    Toggle("Debug Mode", isOn: $viewModel.debugModeEnabled)
                }

                // Reset Section
                Section {
                    Button("Reset Dark Mode") {
                        viewModel.resetDarkMode()
                    }
                    .foregroundColor(.red)

                    Button("Reset Feature Toggles") {
                        viewModel.resetFeatureToggles()
                    }
                    .foregroundColor(.red)
                }

                // System Info Section
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
            .navigationTitle("Settings")
        }
    }
}
