//
//  FavoritesServiceProtocol.swift
//  Model
//
//  Protocol for favorites service
//

import Foundation

@MainActor
public protocol FavoritesServiceProtocol {
    var favorites: Set<String> { get }

    /// Stream that emits when favorites change
    var favoritesStream: AsyncStream<Set<String>> { get }

    func isFavorited(_ itemId: String) -> Bool
    func toggleFavorite(_ itemId: String)
    func addFavorite(_ itemId: String)
    func removeFavorite(_ itemId: String)

    /// Clear all favorites and reset to default state
    func resetFavorites()
}
