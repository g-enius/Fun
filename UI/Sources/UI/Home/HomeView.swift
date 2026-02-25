//
//  HomeView.swift
//  UI
//
//  SwiftUI view for Home screen
//

import SwiftUI

import FunCore
import FunModel
import FunViewModel

public struct HomeView: View {
    @Bindable private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .navigationTitle(L10n.Tabs.home)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.didTapProfile() }) {
                        Image(systemName: "person.circle")
                    }
                    .accessibilityIdentifier(AccessibilityID.Home.profileButton)
                    .accessibilityLabel(L10n.Profile.title)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                Text(L10n.Common.loading)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.hasError {
            ErrorStateView(onRetry: viewModel.retry)
        } else if viewModel.isCarouselEnabled && !viewModel.featuredItems.isEmpty {
            ScrollView {
                CarouselView(
                    featuredItems: viewModel.featuredItems,
                    currentIndex: $viewModel.currentCarouselIndex,
                    isFavorited: viewModel.isFavorited,
                    onItemTap: viewModel.didTapFeaturedItem,
                    onFavoriteTap: { viewModel.toggleFavorite(for: $0) }
                )
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.refresh()
            }
        } else {
            CarouselDisabledView()
        }
    }
}

// MARK: - Carousel View

private struct CarouselView: View {
    let featuredItems: [[FeaturedItem]]
    @Binding var currentIndex: Int
    let isFavorited: (String) -> Bool
    let onItemTap: (FeaturedItem) -> Void
    let onFavoriteTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Home.featured)
                .font(.headline)
                .padding(.horizontal)

            TabView(selection: $currentIndex) {
                ForEach(featuredItems.indices, id: \.self) { index in
                    HStack(spacing: 16) {
                        ForEach(featuredItems[index]) { item in
                            FeaturedCardView(
                                item: item,
                                isFavorited: isFavorited(item.id),
                                onTap: { onItemTap(item) },
                                onFavoriteTap: { onFavoriteTap(item.id) }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 220)
            .accessibilityIdentifier(AccessibilityID.Home.carousel)

            PageIndicatorView(
                currentIndex: currentIndex,
                pageCount: featuredItems.count
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
        }
    }
}

// MARK: - Error State View

private struct ErrorStateView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(.red)
                .accessibilityHidden(true)

            Text(L10n.Error.failedToLoad)
                .font(.title2)
                .fontWeight(.semibold)

            Text(L10n.Error.networkError)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onRetry) {
                Text(L10n.Error.retry)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .accessibilityIdentifier(AccessibilityID.Error.retryButton)
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier(AccessibilityID.Error.errorStateView)
    }
}

// MARK: - Empty State View

private struct CarouselDisabledView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "rectangle.stack.badge.minus")
                .font(.system(size: 64))
                .foregroundColor(.gray)
                .accessibilityHidden(true)

            Text(L10n.Home.carouselDisabled)
                .font(.title2)
                .fontWeight(.semibold)

            Text(L10n.Home.enableFromSettings)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Page Indicator View
// Custom indicator because the built-in .page(indexDisplayMode: .always) renders
// white dots on a white background with no color control.

private struct PageIndicatorView: View {
    let currentIndex: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.Accessibility.pageIndicator(currentIndex + 1, pageCount))
    }
}

// MARK: - Featured Card View

private struct FeaturedCardView: View {
    let item: FeaturedItem
    let isFavorited: Bool
    let onTap: () -> Void
    let onFavoriteTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
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
                .background(Color.named(item.iconColor))
                .cornerRadius(12)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            Button(action: onFavoriteTap) {
                Image(systemName: isFavorited ? "star.fill" : "star")
                    .font(.system(size: 20))
                    .foregroundColor(isFavorited ? .yellow : .white.opacity(0.8))
                    .symbolReplaceTransition()
                    .padding(12)
            }
            .buttonStyle(PressableButtonStyle(.scale(0.85)))
            .symbolBounceEffect(value: isFavorited)
            .selectionFeedback(trigger: isFavorited)
            .accessibilityIdentifier("favorite_button_\(item.id)")
            .accessibilityLabel(isFavorited ? L10n.Detail.removeFromFavorites : L10n.Detail.addToFavorites)
        }
        .accessibilityIdentifier("featured_card_\(item.id)")
        .accessibilityLabel("\(item.title), \(item.subtitle)")
        .accessibilityHint(L10n.Accessibility.doubleTapToViewDetails)
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                HomeView(viewModel: PreviewHelper.makeHomeViewModel())
                    .navigationTitle("Home")
            }
            .previewDisplayName("Home - Carousel")

            ErrorStateView(onRetry: {})
                .previewDisplayName("Error State")

            CarouselDisabledView()
                .previewDisplayName("Carousel Disabled")

            FeaturedCardView(
                item: .asyncAwait,
                isFavorited: true,
                onTap: {},
                onFavoriteTap: {}
            )
            .frame(width: 160, height: 200)
            .padding()
            .previewDisplayName("Featured Card")
        }
    }
}
