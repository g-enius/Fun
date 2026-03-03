//
//  NetworkServiceProtocol.swift
//  Model
//
//  Protocol for network service
//

import Foundation

public protocol NetworkServiceProtocol: Sendable {
    func login() async throws
    func fetchFeaturedItems() async throws -> [[FeaturedItem]]
    func fetchAllItems() async throws -> [FeaturedItem]
    func searchItems(query: String, category: String) async throws -> [FeaturedItem]
}
