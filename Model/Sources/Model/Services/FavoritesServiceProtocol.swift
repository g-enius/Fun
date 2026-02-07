//
//  FavoritesServiceProtocol.swift
//  Model
//
//  Protocol for favorites service
//

import Combine
import Foundation

@MainActor
public protocol FavoritesServiceProtocol {
    var favorites: Set<String> { get }

    /// Publisher that emits when favorites change
    var favoritesDidChange: AnyPublisher<Set<String>, Never> { get }

    func isFavorited(_ itemId: String) -> Bool
    func toggleFavorite(_ itemId: String)
    func addFavorite(_ itemId: String)
    func removeFavorite(_ itemId: String)

    /// Clear all favorites and reset to default state
    func resetFavorites()
}
