//
//  ProfileView.swift
//  UI
//
//  SwiftUI view for Profile screen
//

import SwiftUI
import FunViewModel
import FunCore

public struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    public init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    private var appVersionText: String {
        "\(L10n.Common.version) \(Bundle.main.appVersion) (\(L10n.Common.build) \(Bundle.main.buildNumber))"
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
                    .accessibilityLabel(L10n.Profile.title)

                VStack(spacing: 8) {
                    Text(viewModel.userName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(viewModel.userEmail)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(viewModel.userBio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: { viewModel.didTapSearchItems() }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text(L10n.Profile.searchItems)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .accessibilityLabel(L10n.Profile.searchItems)
                .padding(.horizontal)

                HStack(spacing: 40) {
                    StatView(title: L10n.Profile.views, value: "\(viewModel.viewCount)")
                    StatView(title: L10n.Profile.favorites, value: "\(viewModel.favoritesCount)")
                    StatView(title: L10n.Profile.days, value: "\(viewModel.daysCount)")
                }

                Text(appVersionText)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            .padding(.vertical)
        }
    }
}

private struct StatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
