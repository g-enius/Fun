//
//  Tab3View.swift
//  UI
//
//  SwiftUI view for Tab3 (Items) screen
//

import SwiftUI
import FunViewModel
import FunModel

public struct Tab3View: View {
    @ObservedObject var viewModel: Tab3ViewModel

    public init(viewModel: Tab3ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section(header: Text("Loaded Items")) {
                ForEach(viewModel.items) { item in
                    Button(action: { viewModel.didSelectItem(item) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            if viewModel.isFavorited(item.id) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("item_\(item.id)")
                    .accessibilityLabel("\(item.title), \(item.subtitle)")
                    .swipeActions(edge: .trailing) {
                        Button(action: { viewModel.toggleFavorite(for: item.id) }) {
                            Label(
                                viewModel.isFavorited(item.id) ? "Unfavorite" : "Favorite",
                                systemImage: viewModel.isFavorited(item.id) ? "star.slash" : "star"
                            )
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .accessibilityIdentifier(AccessibilityID.Tab3.itemsList)
    }
}
