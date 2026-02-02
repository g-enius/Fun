//
//  DetailView.swift
//  UI
//
//  SwiftUI view for Detail screen
//

import SwiftUI
import FunViewModel

public struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel

    public init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(viewModel.itemTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {
                    Image(systemName: "folder")
                    Text(viewModel.category)
                    Spacer()
                    Text("Just now")
                        .foregroundColor(.gray)
                }
                .font(.subheadline)

                Divider()

                Text("Description")
                    .font(.headline)
                Text("This is a detailed description of \(viewModel.itemTitle). It showcases the coordinator pattern for navigation in iOS apps.")
                    .foregroundColor(.secondary)

                Divider()

                VStack(spacing: 12) {
                    Button(action: { viewModel.didTapShare() }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .accessibilityIdentifier(AccessibilityID.Detail.shareButton)
                    .accessibilityLabel("Share this item")

                    Button(action: { viewModel.didTapToggleFavorite() }) {
                        HStack {
                            Image(systemName: viewModel.isFavorited ? "heart.fill" : "heart")
                            Text(viewModel.isFavorited ? "Remove from Favorites" : "Add to Favorites")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                    .accessibilityIdentifier(AccessibilityID.Detail.favoriteButton)
                    .accessibilityLabel(viewModel.isFavorited ? "Remove from favorites" : "Add to favorites")

                    Button(action: { viewModel.didTapSwitchToTab2() }) {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text("Switch to Tab 2")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Switch to Search tab")
                }

                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Push Navigation")
                            .font(.caption)
                    }
                    Text("Using Coordinator Pattern")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
            }
            .padding()
        }
    }
}
