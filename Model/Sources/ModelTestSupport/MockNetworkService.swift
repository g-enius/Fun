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
    public var mockData: Data?
    public var mockError: Error?

    public init() {}

    public func fetch<T: Decodable>(from url: URL) async throws -> T {
        if let error = mockError {
            throw error
        }
        guard let data = mockData else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func fetchData(from url: URL) async throws -> Data {
        if let error = mockError {
            throw error
        }
        guard let data = mockData else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
