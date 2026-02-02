//
//  Tab2View.swift
//  UI
//
//  SwiftUI view for Tab2 (Search) screen
//

import SwiftUI
import FunViewModel
import FunModel

public struct Tab2View: View {
    @ObservedObject var viewModel: Tab2ViewModel

    public init(viewModel: Tab2ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
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
            .accessibilityIdentifier(AccessibilityID.Tab2.categoryPicker)

            if viewModel.isSearching {
                Spacer()
                ProgressView(L10n.Search.searching)
                    .progressViewStyle(.circular)
                Spacer()
            } else if viewModel.searchResults.isEmpty {
                Spacer()
                EmptySearchResultsView(message: emptyStateMessage)
                Spacer()
            } else {
                List(viewModel.searchResults) { result in
                    Button(action: { viewModel.didSelectResult(result) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .font(.headline)
                            Text(result.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(result.category)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("search_result_\(result.id)")
                    .accessibilityLabel("\(result.title), \(result.subtitle)")
                }
                .listStyle(.plain)
                .accessibilityIdentifier(AccessibilityID.Tab2.resultsList)
            }

            SearchBarView(
                text: $viewModel.searchText,
                isSearching: viewModel.isSearching,
                minimumCharacters: viewModel.minimumSearchCharacters,
                onClear: { viewModel.clearSearch() }
            )
            .accessibilityIdentifier(AccessibilityID.Tab2.searchField)
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

// MARK: - Search Bar View

struct SearchBarView: View {
    @Binding var text: String
    let isSearching: Bool
    let minimumCharacters: Int
    let onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                // Search icon or loading indicator
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
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if isFocused {
                Button(L10n.Common.cancel) {
                    text = ""
                    isFocused = false
                    onClear()
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Empty Results View

struct EmptySearchResultsView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
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
