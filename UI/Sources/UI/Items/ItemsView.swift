//
//  ItemsView.swift
//  UI
//
//  SwiftUI view for Items screen - combines search, filter, and items list
//

import SwiftUI

import FunCore
import FunModel
import FunViewModel

public struct ItemsView: View {
    @ObservedObject var viewModel: ItemsViewModel

    public init(viewModel: ItemsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ItemsMainContent(viewModel: viewModel)
    }
}

// MARK: - Content View

private struct ItemsMainContent: View {
    @ObservedObject var viewModel: ItemsViewModel

    var body: some View {
        VStack(spacing: 0) {
            CategoryFilterView(viewModel: viewModel)
            ItemsContentView(viewModel: viewModel)

            SearchBarView(
                text: $viewModel.searchText,
                isSearching: viewModel.isSearching,
                minimumCharacters: viewModel.minimumSearchCharacters,
                onClear: { viewModel.clearSearch() }
            )
            .accessibilityIdentifier(AccessibilityID.Items.searchField)
        }
    }
}

// MARK: - Shared Components

private struct CategoryFilterView: View {
    @ObservedObject var viewModel: ItemsViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Button(action: { viewModel.didSelectCategory(category) }) {
                        Text(category)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedCategory == category
                                    ? Color.blue
                                    : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(
                                viewModel.selectedCategory == category
                                    ? .white
                                    : .primary
                            )
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("category_\(category)")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .accessibilityIdentifier(AccessibilityID.Items.categoryPicker)
    }
}

private struct ItemsContentView: View {
    @ObservedObject var viewModel: ItemsViewModel

    var body: some View {
        if viewModel.isSearching {
            Spacer()
            ProgressView(L10n.Search.searching)
                .progressViewStyle(.circular)
            Spacer()
        } else if viewModel.hasError {
            Spacer()
            ItemsErrorStateView(onRetry: viewModel.retry)
            Spacer()
        } else if viewModel.needsMoreCharacters {
            Spacer()
            KeepTypingView(minimumCharacters: viewModel.minimumSearchCharacters)
            Spacer()
        } else if viewModel.items.isEmpty {
            Spacer()
            EmptyItemsView(message: emptyStateMessage)
            Spacer()
        } else {
            List {
                ForEach(viewModel.items) { item in
                    ItemRowView(item: item, viewModel: viewModel)
                }
            }
            .listStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.Items.itemsList)
        }
    }

    private var emptyStateMessage: String {
        let trimmed = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed.count < viewModel.minimumSearchCharacters {
            return L10n.Search.typeMinCharacters(viewModel.minimumSearchCharacters)
        }
        return L10n.Search.tryDifferentTerm
    }
}

private struct ItemRowView: View {
    let item: FeaturedItem
    @ObservedObject var viewModel: ItemsViewModel

    private var isFavorited: Bool {
        viewModel.isFavorited(item.id)
    }

    var body: some View {
        Button(action: { viewModel.didSelectItem(item) }) {
            HStack(spacing: 12) {
                Image(systemName: item.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.named(item.iconColor))
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                Spacer()

                Button(action: { viewModel.toggleFavorite(for: item.id) }) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .font(.system(size: 20))
                        .foregroundColor(isFavorited ? .yellow : .gray)
                        .symbolReplaceTransition()
                }
                .buttonStyle(.plain)
                .symbolBounceEffect(value: isFavorited)
                .selectionFeedback(trigger: isFavorited)
                .accessibilityIdentifier("favorite_button_\(item.id)")
                .accessibilityLabel(
                    isFavorited
                        ? L10n.Detail.removeFromFavorites
                        : L10n.Detail.addToFavorites
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("item_\(item.id)")
        .accessibilityLabel("\(item.title), \(item.subtitle)")
        .swipeActions(edge: .trailing) {
            Button(action: { viewModel.toggleFavorite(for: item.id) }) {
                Label(
                    isFavorited ? L10n.Items.unfavorite : L10n.Items.favorite,
                    systemImage: isFavorited ? "star.slash" : "star"
                )
            }
            .tint(.yellow)
        }
    }
}

// MARK: - Search Bar View

private struct SearchBarView: View {
    @Binding var text: String
    let isSearching: Bool
    let minimumCharacters: Int
    let onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                if isSearching {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                }

                TextField(L10n.Search.minCharacters(minimumCharacters), text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .submitLabel(.search)

                if !text.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.Common.cancel)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            Button(L10n.Common.cancel) {
                text = ""
                isFocused = false
                onClear()
            }
            .foregroundColor(.blue)
            .opacity(isFocused ? 1 : 0)
            .disabled(!isFocused)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

// MARK: - Keep Typing View

private struct KeepTypingView: View {
    let minimumCharacters: Int

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "keyboard")
                .font(.system(size: 48))
                .foregroundColor(.gray)
                .accessibilityHidden(true)
            Text(L10n.Search.keepTyping)
                .font(.title2)
                .fontWeight(.semibold)
            Text(L10n.Search.typeMinCharacters(minimumCharacters))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Empty Items View

private struct EmptyItemsView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
                .accessibilityHidden(true)
            Text(L10n.Search.noResults)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Error State View

private struct ItemsErrorStateView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
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
        }
        .accessibilityIdentifier(AccessibilityID.Error.itemsErrorStateView)
    }
}

// MARK: - Previews

struct ItemsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ItemsView(viewModel: PreviewHelper.makeItemsViewModel())
                    .navigationTitle("Items")
            }
            .previewDisplayName("Items List")

            SearchBarView(
                text: .constant("Swift"),
                isSearching: false,
                minimumCharacters: 2,
                onClear: {}
            )
            .previewDisplayName("Search Bar")

            SearchBarView(
                text: .constant("async"),
                isSearching: true,
                minimumCharacters: 2,
                onClear: {}
            )
            .previewDisplayName("Search Bar - Searching")

            KeepTypingView(minimumCharacters: 2)
                .previewDisplayName("Keep Typing")

            EmptyItemsView(message: "Try a different search term")
                .previewDisplayName("Empty Results")

            ItemsErrorStateView(onRetry: {})
                .previewDisplayName("Error State")
        }
    }
}
