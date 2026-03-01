//
//  MockFavoritesService.swift
//  Model
//
//  Mock implementation of FavoritesServiceProtocol for testing
//

import FunCore
import FunModel

@MainActor
public final class MockFavoritesService: FavoritesServiceProtocol {

    public private(set) var favorites: Set<String>

    private let favoritesBroadcaster = StreamBroadcaster<Set<String>>()

    public var favoritesStream: AsyncStream<Set<String>> {
        favoritesBroadcaster.makeStream()
    }

    public init(initialFavorites: Set<String> = []) {
        self.favorites = initialFavorites
    }

    public func isFavorited(_ itemId: String) -> Bool {
        favorites.contains(itemId)
    }

    public func toggleFavorite(_ itemId: String) {
        if favorites.contains(itemId) {
            favorites.remove(itemId)
        } else {
            favorites.insert(itemId)
        }
        favoritesBroadcaster.yield(favorites)
    }

    public func addFavorite(_ itemId: String) {
        favorites.insert(itemId)
        favoritesBroadcaster.yield(favorites)
    }

    public func removeFavorite(_ itemId: String) {
        favorites.remove(itemId)
        favoritesBroadcaster.yield(favorites)
    }

    public func resetFavorites() {
        favorites.removeAll()
        favoritesBroadcaster.yield(favorites)
    }
}
