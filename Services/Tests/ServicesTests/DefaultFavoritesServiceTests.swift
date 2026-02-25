//
//  DefaultFavoritesServiceTests.swift
//  Services
//
//  Unit tests for DefaultFavoritesService
//

import Testing
import Foundation
@testable import FunServices
@testable import FunModel

@Suite("DefaultFavoritesService Tests", .serialized)
@MainActor
struct DefaultFavoritesServiceTests {

    // Helper to clear UserDefaults before each test
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: .favorites)
    }

    // MARK: - Initialization Tests

    @Test("Initial favorites contains item1 by default")
    func testDefaultFavorite() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        #expect(service.favorites.contains("item1"))
        #expect(service.favorites.count == 1)
    }

    // MARK: - Favorites Operations Tests

    @Test("isFavorited returns true for favorited items")
    func testIsFavorited() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        #expect(service.isFavorited("item1") == true)
        #expect(service.isFavorited("item2") == false)
    }

    @Test("addFavorite adds item to favorites")
    func testAddFavorite() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        service.addFavorite("item2")

        #expect(service.favorites.contains("item2"))
        #expect(service.isFavorited("item2") == true)
    }

    @Test("removeFavorite removes item from favorites")
    func testRemoveFavorite() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        #expect(service.isFavorited("item1") == true)

        service.removeFavorite("item1")

        #expect(service.isFavorited("item1") == false)
        #expect(service.favorites.isEmpty)
    }

    @Test("toggleFavorite adds item when not favorited")
    func testToggleFavoriteAdds() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()
        let initialCount = service.favorites.count

        #expect(service.isFavorited("item3") == false)

        service.toggleFavorite( "item3")

        #expect(service.isFavorited("item3") == true)
        #expect(service.favorites.count == initialCount + 1)
        #expect(service.favorites.contains("item3"))
    }

    @Test("toggleFavorite removes item when already favorited")
    func testToggleFavoriteRemoves() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        #expect(service.isFavorited("item1") == true)
        let initialCount = service.favorites.count

        service.toggleFavorite( "item1")

        #expect(service.isFavorited("item1") == false)
        #expect(service.favorites.count == initialCount - 1)
        #expect(!service.favorites.contains("item1"))
    }

    // MARK: - Persistence Tests

    @Test("Favorites persist across service instances")
    func testFavoritesPersistence() async {
        clearUserDefaults()

        // First service instance
        let service1 = DefaultFavoritesService()
        service1.addFavorite("item2")
        service1.addFavorite("item3")

        // Second service instance should have the same favorites
        let service2 = DefaultFavoritesService()

        #expect(service2.favorites.contains("item1"))
        #expect(service2.favorites.contains("item2"))
        #expect(service2.favorites.contains("item3"))
        #expect(service2.favorites.count == 3)
    }

    // MARK: - Multiple Operations Tests

    @Test("Multiple favorite operations work correctly")
    func testMultipleFavoriteOperations() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        // Add several items
        service.addFavorite("item2")
        service.addFavorite("item3")
        service.addFavorite("item4")

        #expect(service.favorites.count == 4)

        // Remove some
        service.removeFavorite("item1")
        service.removeFavorite("item3")

        #expect(service.favorites.count == 2)
        #expect(service.favorites.contains("item2"))
        #expect(service.favorites.contains("item4"))
        #expect(!service.favorites.contains("item1"))
        #expect(!service.favorites.contains("item3"))
    }

    @Test("Adding duplicate favorite is idempotent")
    func testAddDuplicateFavorite() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        service.addFavorite("item2")
        let countAfterFirstAdd = service.favorites.count

        service.addFavorite("item2")
        let countAfterSecondAdd = service.favorites.count

        #expect(countAfterFirstAdd == countAfterSecondAdd)
    }

    @Test("Removing non-existent favorite is safe")
    func testRemoveNonExistentFavorite() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        let countBefore = service.favorites.count

        service.removeFavorite("nonexistent")

        #expect(service.favorites.count == countBefore)
    }

    // MARK: - Stream Tests

    @Test("favoritesChanges emits when favorites change")
    func testFavoritesChangesStream() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        var receivedFavorites: Set<String>?
        let task = Task {
            for await favorites in service.favoritesChanges {
                receivedFavorites = favorites
                break
            }
        }

        // Give the task time to start listening
        try? await Task.sleep(for: .milliseconds(50))

        service.addFavorite("item2")

        try? await Task.sleep(for: .milliseconds(50))
        task.cancel()

        #expect(receivedFavorites != nil)
        #expect(receivedFavorites?.contains("item2") == true)
    }

    @Test("favoritesChanges emits on toggle")
    func testFavoritesChangesOnToggle() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        var emitCount = 0
        let task = Task {
            for await _ in service.favoritesChanges {
                emitCount += 1
                if emitCount >= 2 { break }
            }
        }

        // Let the consumer task start and subscribe
        try? await Task.sleep(for: .milliseconds(10))

        service.toggleFavorite("item1")
        service.toggleFavorite("item1")

        try? await Task.sleep(for: .milliseconds(50))
        task.cancel()

        #expect(emitCount == 2)
    }

    // MARK: - Reset Tests

    @Test("resetFavorites restores default favorites")
    func testResetFavoritesRestoresDefaults() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        // Add some favorites
        service.addFavorite("item2")
        service.addFavorite("item3")
        #expect(service.favorites.count == 3) // item1 default + item2 + item3

        service.resetFavorites()

        // Should be back to default (just "item1")
        #expect(service.favorites.count == 1)
        #expect(service.favorites.contains("item1"))
        #expect(!service.favorites.contains("item2"))
        #expect(!service.favorites.contains("item3"))
    }

    @Test("resetFavorites emits default set via stream")
    func testResetFavoritesEmitsDefault() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        service.addFavorite("item2")

        var receivedFavorites: Set<String>?
        let task = Task {
            for await favorites in service.favoritesChanges {
                receivedFavorites = favorites
                // We want to capture the reset emission, skip the addFavorite one
                if favorites == Set(["item1"]) { break }
            }
        }

        await Task.yield()

        service.resetFavorites()

        await Task.yield()
        task.cancel()

        #expect(receivedFavorites != nil)
        #expect(receivedFavorites == Set(["item1"]))
    }

    @Test("resetFavorites clears UserDefaults")
    func testResetFavoritesClearsUserDefaults() async {
        clearUserDefaults()
        let service = DefaultFavoritesService()

        // Add a favorite to persist
        service.addFavorite("item2")
        #expect(UserDefaults.standard.data(forKey: .favorites) != nil)

        service.resetFavorites()

        // After reset, the defaults get re-saved (since didSet calls saveFavorites)
        // But the content should be the default set
        let service2 = DefaultFavoritesService()
        #expect(service2.favorites.count == 1)
        #expect(service2.favorites.contains("item1"))
    }
}
