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

// MARK: - Swift Concurrency Alternative (iOS 15+)
//
// AsyncStream replaces AnyPublisher for service event delivery.
// No Combine import needed. Available from iOS 15 (same as this branch).
//
//     // Protocol
//     var favoritesChanges: AsyncStream<Set<String>> { get }
//
//     // Consumer — Task cancellation replaces AnyCancellable
//     let stream = favoritesService.favoritesChanges
//     observation = Task { [weak self] in
//         for await favorites in stream {
//             guard let self else { break }   // guard INSIDE loop to avoid retain cycle
//             self.favoriteIds = favorites
//         }
//     }
//
// Key difference: AsyncStream only delivers future values (unlike @Published which emits
// the current value on subscribe). Read the property directly at init time:
//     favoriteIds = favoritesService.favorites      // current
//     // then subscribe to favoritesChanges          // future
//
// See feature/async-sequence for the full implementation.
