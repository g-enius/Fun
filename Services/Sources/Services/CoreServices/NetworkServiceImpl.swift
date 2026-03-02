//
//  NetworkServiceImpl.swift
//  Services
//
//  Actor-based implementation of NetworkService
//

import Foundation
import FunModel

public actor NetworkServiceImpl: NetworkService {

    private let shouldSimulateErrors: @MainActor @Sendable () -> Bool

    public init(shouldSimulateErrors: @escaping @MainActor @Sendable () -> Bool = { false }) {
        self.shouldSimulateErrors = shouldSimulateErrors
    }

    public func login() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    public func fetchFeaturedItems() async throws -> [[FeaturedItem]] {
        try await throwIfSimulatingErrors()
        let delay = UInt64.random(in: 1_000_000_000...2_000_000_000)
        try await Task.sleep(nanoseconds: delay)
        return FeaturedItem.allCarouselSets.shuffled().map { $0.shuffled() }
    }

    public func fetchAllItems() async throws -> [FeaturedItem] {
        try await throwIfSimulatingErrors()
        let delay = UInt64.random(in: 500_000_000...1_000_000_000)
        try await Task.sleep(nanoseconds: delay)
        return FeaturedItem.all
    }

    public func searchItems(query: String, category: String) async throws -> [FeaturedItem] {
        try await throwIfSimulatingErrors()
        let delay = UInt64.random(in: 300_000_000...800_000_000)
        try await Task.sleep(nanoseconds: delay)

        var results = FeaturedItem.all

        if !category.isEmpty && category != "All" {
            results = results.filter { $0.category == category }
        }

        let lowercasedQuery = query.lowercased()
        if !lowercasedQuery.isEmpty {
            results = results.filter { item in
                item.title.lowercased().contains(lowercasedQuery) ||
                item.subtitle.lowercased().contains(lowercasedQuery)
            }
        }

        return results.shuffled()
    }

    private func throwIfSimulatingErrors() async throws {
        guard await shouldSimulateErrors() else { return }
        let delay = UInt64.random(in: 1_000_000_000...2_000_000_000)
        try await Task.sleep(nanoseconds: delay)
        throw AppError.networkError
    }
}
