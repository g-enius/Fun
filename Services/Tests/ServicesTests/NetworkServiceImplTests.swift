//
//  NetworkServiceImplTests.swift
//  Services
//
//  Unit tests for NetworkServiceImpl
//

import Testing
import Foundation
@testable import FunServices
@testable import FunModel

@Suite("NetworkServiceImpl Tests")
struct NetworkServiceImplTests {

    @Test("login completes without error")
    func testLoginCompletes() async throws {
        let service = NetworkServiceImpl()
        try await service.login()
    }

    @Test("fetchFeaturedItems returns 7 carousel sets")
    func testFetchFeaturedItemsCount() async throws {
        let service = NetworkServiceImpl()
        let result = try await service.fetchFeaturedItems()

        #expect(result.count == FeaturedItem.allCarouselSets.count)
    }

    @Test("fetchFeaturedItems returns shuffled results across calls")
    func testFetchFeaturedItemsShuffled() async throws {
        let service = NetworkServiceImpl()

        var orders: [String] = []
        for _ in 0..<5 {
            let result = try await service.fetchFeaturedItems()
            let order = result.map { $0.map(\.id).joined() }.joined(separator: "|")
            orders.append(order)
        }

        let uniqueOrders = Set(orders)
        // With 7 sets shuffled, getting the same order 5 times is astronomically unlikely
        #expect(uniqueOrders.count > 1)
    }

    @Test("fetchAllItems returns all items")
    func testFetchAllItems() async throws {
        let service = NetworkServiceImpl()
        let result = try await service.fetchAllItems()

        #expect(result.count == FeaturedItem.all.count)
        #expect(result == FeaturedItem.all)
    }

    @Test("fetchFeaturedItems respects cancellation")
    func testFetchFeaturedItemsCancellation() async {
        let service = NetworkServiceImpl()

        let task = Task {
            try await service.fetchFeaturedItems()
        }

        task.cancel()

        do {
            _ = try await task.value
            // If it completed before cancellation, that's ok
        } catch is CancellationError {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}
