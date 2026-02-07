//
//  DefaultFavoritesService.swift
//  Services
//
//  Default implementation of FavoritesServiceProtocol
//

import Combine
import Foundation
import OSLog

import FunModel

@MainActor
public final class DefaultFavoritesService: FavoritesServiceProtocol {

    private static let defaultFavorites: Set<String> = ["item1"]
    private let logger = Logger(subsystem: "com.fun.app", category: "favorites")

    public private(set) var favorites: Set<String> {
        didSet {
            saveFavorites()
            favoritesSubject.send(favorites)
        }
    }

    private let favoritesSubject: CurrentValueSubject<Set<String>, Never>

    public var favoritesDidChange: AnyPublisher<Set<String>, Never> {
        favoritesSubject.eraseToAnyPublisher()
    }

    public init() {
        let loaded: Set<String>
        if let data = UserDefaults.standard.data(forKey: .favorites) {
            do {
                loaded = try JSONDecoder().decode(Set<String>.self, from: data)
            } catch {
                logger.error("Failed to decode favorites: \(error.localizedDescription)")
                loaded = Self.defaultFavorites
            }
        } else {
            loaded = Self.defaultFavorites
        }
        self.favorites = loaded
        self.favoritesSubject = CurrentValueSubject(loaded)
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

    public func resetFavorites() {
        UserDefaults.standard.removeObject(forKey: .favorites)
        favorites = Self.defaultFavorites
    }

    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: .favorites)
        } catch {
            logger.error("Failed to encode favorites: \(error.localizedDescription)")
        }
    }
}
