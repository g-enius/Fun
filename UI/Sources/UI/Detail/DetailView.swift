//
//  DetailView.swift
//  UI
//
//  SwiftUI view for Detail screen
//

import SwiftUI
import FunViewModel
import FunModel

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
                    Text(L10n.Detail.justNow)
                        .foregroundColor(.gray)
                }
                .font(.subheadline)

                Divider()

                Text(L10n.Detail.description)
                    .font(.headline)
                Text(L10n.Detail.itemDescription(viewModel.itemTitle))
                    .foregroundColor(.secondary)

                Divider()

                VStack(spacing: 12) {
                    Button(action: { viewModel.didTapShare() }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text(L10n.Common.share)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .accessibilityIdentifier(AccessibilityID.Detail.shareButton)
                    .accessibilityLabel(L10n.Common.share)

                    Button(action: { viewModel.didTapToggleFavorite() }) {
                        HStack {
                            Image(systemName: viewModel.isFavorited ? "heart.fill" : "heart")
                            Text(viewModel.isFavorited ? L10n.Detail.removeFromFavorites : L10n.Detail.addToFavorites)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                    .accessibilityIdentifier(AccessibilityID.Detail.favoriteButton)
                    .accessibilityLabel(
                        viewModel.isFavorited
                            ? L10n.Detail.removeFromFavorites
                            : L10n.Detail.addToFavorites
                    )

                    Button(action: { viewModel.didTapSwitchToTab2() }) {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text(L10n.Home.switchToTab2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.Tabs.search)
                }

                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(L10n.Detail.pushNavigation)
                            .font(.caption)
                    }
                    Text(L10n.Detail.usingCoordinatorPattern)
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
