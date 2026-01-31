//
//  DefaultFavoritesService.swift
//  Services
//
//  Default implementation of FavoritesServiceProtocol
//

import Foundation
import FunModel

@MainActor
public final class DefaultFavoritesService: FavoritesServiceProtocol {

    private let userDefaultsKey = "app.favorites"

    public private(set) var favorites: Set<String> {
        didSet {
            saveFavorites()
        }
    }

    public init() {
        // Load favorites from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.favorites = decoded
        } else {
            // Default: item1 is favorited
            self.favorites = ["item1"]
        }
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
    }

    public func addFavorite(_ itemId: String) {
        favorites.insert(itemId)
    }

    public func removeFavorite(_ itemId: String) {
        favorites.remove(itemId)
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
