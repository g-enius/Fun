//
//  Tab3ViewModel.swift
//  ViewModel
//
//  ViewModel for Tab3 (Items) screen
//

import Foundation
import Combine
import FunModel
import FunToolbox

@MainActor
public class Tab3ViewModel: ObservableObject {

    // MARK: - Coordinator

    private weak var coordinator: Tab3Coordinator?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService
    @Service(.favorites) private var favoritesService: FavoritesServiceProtocol

    // MARK: - Published State

    @Published public var items: [ListItem] = []

    // MARK: - Initialization

    public init(coordinator: Tab3Coordinator?) {
        self.coordinator = coordinator
        loadItems()
    }

    // MARK: - Data Loading

    public func loadItems() {
        items = [
            ListItem(id: "item1", title: "Item 1", subtitle: "Description for item 1"),
            ListItem(id: "item2", title: "Item 2", subtitle: "Description for item 2"),
            ListItem(id: "item3", title: "Item 3", subtitle: "Description for item 3"),
            ListItem(id: "item4", title: "Item 4", subtitle: "Description for item 4"),
            ListItem(id: "item5", title: "Item 5", subtitle: "Description for item 5")
        ]
    }

    // MARK: - Favorites

    public func isFavorited(_ itemId: String) -> Bool {
        favoritesService.isFavorited(itemId)
    }

    public func toggleFavorite(for itemId: String) {
        favoritesService.toggleFavorite(forKey: itemId)
        objectWillChange.send()
    }

    // MARK: - Actions

    public func didSelectItem(_ item: ListItem) {
        logger.log("Item selected: \(item.title)")
        coordinator?.showDetail(for: item.title)
    }
}
