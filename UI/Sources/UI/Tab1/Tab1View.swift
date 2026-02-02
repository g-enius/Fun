//
//  Tab1View.swift
//  UI
//
//  SwiftUI view for Tab1 (Home) screen
//

import SwiftUI
import FunViewModel
import FunModel

public struct Tab1View: View {
    @ObservedObject var viewModel: Tab1ViewModel

    public init(viewModel: Tab1ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isCarouselEnabled && !viewModel.featuredItems.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Featured")
                                    .font(.headline)
                                    .padding(.horizontal)

                                TabView(selection: $viewModel.currentCarouselIndex) {
                                    ForEach(Array(viewModel.featuredItems.enumerated()), id: \.offset) { index, items in
                                        HStack(spacing: 16) {
                                            ForEach(items) { item in
                                                FeaturedCardView(item: item) {
                                                    viewModel.didTapFeaturedItem(item)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .automatic))
                                .frame(height: 200)
                                .accessibilityIdentifier(AccessibilityID.Tab1.carousel)
                            }
                        }

                        VStack(spacing: 12) {
                            Button(action: { viewModel.didTapSettings() }) {
                                HStack {
                                    Image(systemName: "gearshape")
                                    Text("Settings")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier(AccessibilityID.Tab1.settingsButton)
                            .accessibilityLabel("Open Settings")

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
                            .accessibilityIdentifier(AccessibilityID.Tab1.switchTabButton)
                            .accessibilityLabel("Switch to Search tab")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
    }
}

struct FeaturedCardView: View {
    let item: FeaturedItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding()
            .background(cardColor(for: item.color))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("featured_card_\(item.id)")
        .accessibilityLabel("\(item.title), \(item.subtitle)")
        .accessibilityHint("Double tap to view details")
    }

    private func cardColor(for colorName: String) -> Color {
        switch colorName {
        case "green": return .green
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        default: return .gray
        }
    }
}
