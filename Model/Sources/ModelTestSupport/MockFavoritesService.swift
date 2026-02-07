//
//  MockFavoritesService.swift
//  Model
//
//  Mock implementation of FavoritesServiceProtocol for testing
//

import Foundation
import Combine
import FunModel

@MainActor
public final class MockFavoritesService: FavoritesServiceProtocol {

    public private(set) var favorites: Set<String>

    private let favoritesSubject = PassthroughSubject<Set<String>, Never>()

    public var favoritesDidChange: AnyPublisher<Set<String>, Never> {
        favoritesSubject.eraseToAnyPublisher()
    }

    public init(initialFavorites: Set<String> = []) {
        self.favorites = initialFavorites
    }

    public func isFavorited(_ itemId: String) -> Bool {
        favorites.contains(itemId)
    }

    public func toggleFavorite(forKey itemId: String) {
        if favorites.contains(itemId) {
            favorites.remove(itemId)
        } else {
            favorites.insert(itemId)
        }
        favoritesSubject.send(favorites)
    }

    public func addFavorite(_ itemId: String) {
        favorites.insert(itemId)
        favoritesSubject.send(favorites)
    }

    public func removeFavorite(_ itemId: String) {
        favorites.remove(itemId)
        favoritesSubject.send(favorites)
    }

    public func resetFavorites() {
        favorites.removeAll()
        favoritesSubject.send(favorites)
    }
}
