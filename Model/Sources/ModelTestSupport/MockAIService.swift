//
//  MockAIService.swift
//  Model
//
//  Mock implementation of AIServiceProtocol for testing
//

import Foundation
import FunModel

@MainActor
public final class MockAIService: AIServiceProtocol {

    public var isAvailable: Bool
    public var stubbedSummary: String
    public var shouldThrowError: Bool
    public var summarizeCallCount = 0

    public init(isAvailable: Bool = true, stubbedSummary: String = "Mock summary", shouldThrowError: Bool = false) {
        self.isAvailable = isAvailable
        self.stubbedSummary = stubbedSummary
        self.shouldThrowError = shouldThrowError
    }

    public func summarize(_ text: String) async throws -> String {
        summarizeCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        return stubbedSummary
    }
}
