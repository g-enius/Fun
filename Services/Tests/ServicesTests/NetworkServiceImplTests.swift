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

    @Test("login respects cancellation")
    func testLoginCancellation() async {
        let service = NetworkServiceImpl()

        let task = Task {
            try await service.login()
        }

        task.cancel()

        do {
            try await task.value
        } catch is CancellationError {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("fetchAllItems respects cancellation")
    func testFetchAllItemsCancellation() async {
        let service = NetworkServiceImpl()

        let task = Task {
            try await service.fetchAllItems()
        }

        task.cancel()

        do {
            _ = try await task.value
        } catch is CancellationError {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
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
        } catch is CancellationError {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("searchItems returns filtered results matching query")
    func testSearchItemsFiltersResults() async throws {
        let service = NetworkServiceImpl()

        let results = try await service.searchItems(query: "swift", category: "All")

        #expect(!results.isEmpty)
        for item in results {
            let matchesTitle = item.title.lowercased().contains("swift")
            let matchesSubtitle = item.subtitle.lowercased().contains("swift")
            #expect(matchesTitle || matchesSubtitle)
        }
    }

    @Test("searchItems filters by category")
    func testSearchItemsFiltersByCategory() async throws {
        let service = NetworkServiceImpl()

        let results = try await service.searchItems(query: "", category: "Testing")

        #expect(!results.isEmpty)
        for item in results {
            #expect(item.category == "Testing")
        }
    }

    @Test("searchItems respects cancellation")
    func testSearchItemsCancellation() async {
        let service = NetworkServiceImpl()

        let task = Task {
            try await service.searchItems(query: "swift", category: "All")
        }

        task.cancel()

        do {
            _ = try await task.value
        } catch is CancellationError {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}
