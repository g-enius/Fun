//
//  ProfileView.swift
//  UI
//
//  SwiftUI view for Profile screen
//

import SwiftUI
import FunViewModel

public struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    public init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
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
                    .accessibilityLabel("Profile avatar")

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

                Button(action: { viewModel.didTapEditProfile() }) {
                    Text("Edit Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .accessibilityLabel("Edit your profile")

                HStack(spacing: 40) {
                    StatView(title: "Views", value: "\(viewModel.viewCount)")
                    StatView(title: "Favorites", value: "\(viewModel.favoritesCount)")
                    StatView(title: "Days", value: "\(viewModel.daysCount)")
                }

                Text("Version 1.0.0 (Build 42)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            .padding(.vertical)
        }
    }
}

struct StatView: View {
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
