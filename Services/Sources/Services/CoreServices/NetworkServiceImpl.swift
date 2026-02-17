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
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    public func fetchFeaturedItems() async throws -> [[FeaturedItem]] {
        let delay = UInt64.random(in: 1_000_000_000...2_000_000_000)
        try await Task.sleep(nanoseconds: delay)
        return FeaturedItem.allCarouselSets.shuffled().map { $0.shuffled() }
    }

    public func fetchAllItems() async throws -> [FeaturedItem] {
        FeaturedItem.all
    }
}
