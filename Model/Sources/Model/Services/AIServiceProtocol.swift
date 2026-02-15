//
//  AIServiceProtocol.swift
//  Model
//
//  Protocol for on-device AI summarization service
//

import Foundation

@MainActor
public protocol AIServiceProtocol {
    var isAvailable: Bool { get }
    func summarize(_ text: String) async throws -> String
}
