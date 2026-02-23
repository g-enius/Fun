//
//  MockNetworkService.swift
//  Model
//
//  Mock implementation of NetworkService for testing
//

import Foundation
import FunModel

@MainActor
public final class MockNetworkService: NetworkService {

    public var stubbedFeaturedItems: [[FeaturedItem]]
    public var stubbedAllItems: [FeaturedItem]
    public var stubbedSearchItems: [FeaturedItem]
    public var shouldThrowError: Bool
    public var loginCallCount = 0
    public var fetchFeaturedItemsCallCount = 0
    public var fetchAllItemsCallCount = 0
    public var searchItemsCallCount = 0
    public var lastSearchQuery: String?
    public var lastSearchCategory: String?

    public init(
        stubbedFeaturedItems: [[FeaturedItem]] = FeaturedItem.allCarouselSets,
        stubbedAllItems: [FeaturedItem] = FeaturedItem.all,
        stubbedSearchItems: [FeaturedItem] = [],
        shouldThrowError: Bool = false
    ) {
        self.stubbedFeaturedItems = stubbedFeaturedItems
        self.stubbedAllItems = stubbedAllItems
        self.stubbedSearchItems = stubbedSearchItems
        self.shouldThrowError = shouldThrowError
    }

    public func login() async throws {
        loginCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockNetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
    }

    public func fetchFeaturedItems() async throws -> [[FeaturedItem]] {
        fetchFeaturedItemsCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockNetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        return stubbedFeaturedItems
    }

    public func fetchAllItems() async throws -> [FeaturedItem] {
        fetchAllItemsCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockNetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        return stubbedAllItems
    }

    public func searchItems(query: String, category: String) async throws -> [FeaturedItem] {
        searchItemsCallCount += 1
        lastSearchQuery = query
        lastSearchCategory = category
        if shouldThrowError {
            throw NSError(domain: "MockNetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        return stubbedSearchItems
    }
}
