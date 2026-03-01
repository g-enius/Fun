//
//  NetworkServiceImpl.swift
//  Services
//
//  Actor-based implementation of NetworkService
//

import Foundation
import FunModel

public actor NetworkServiceImpl: NetworkService {

    public init() {}

    public func login() async throws {
        try await Task.sleep(for: .milliseconds(500))
    }

    public func fetchFeaturedItems() async throws -> [[FeaturedItem]] {
        try await Task.sleep(for: .milliseconds(.random(in: 1000...2000)))
        return FeaturedItem.allCarouselSets.shuffled().map { $0.shuffled() }
    }

    public func fetchAllItems() async throws -> [FeaturedItem] {
        try await Task.sleep(for: .milliseconds(.random(in: 500...1000)))
        return FeaturedItem.all
    }

    public func searchItems(query: String, category: String) async throws -> [FeaturedItem] {
        try await Task.sleep(for: .milliseconds(.random(in: 300...800)))

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
}
