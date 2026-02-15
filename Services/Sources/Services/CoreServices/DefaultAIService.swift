//
//  DefaultAIService.swift
//  Services
//
//  On-device AI summarization using Apple Foundation Models (iOS 26+)
//

import Foundation

import FunModel

#if canImport(FoundationModels)
import FoundationModels
#endif

#if canImport(FoundationModels)
@available(iOS 26, *)
@Generable
struct AISummary {
    @Guide(description: "A concise 2-3 sentence summary of the text")
    var summary: String
}
#endif

@MainActor
public final class DefaultAIService: AIServiceProtocol {

    public var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            // Apple beta bug: SystemLanguageModel.default.isAvailable returns true on simulator
            // but generation fails with GenerationError -1. Treat simulator as unavailable.
            // https://developer.apple.com/forums/thread/792022
            #if targetEnvironment(simulator)
            return false
            #else
            return SystemLanguageModel.default.isAvailable
            #endif
        }
        #endif
        return false
    }

    public init() {}

    public func summarize(_ text: String) async throws -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            let session = LanguageModelSession(
                instructions: "Summarize the following text concisely in 2-3 sentences."
            )
            let response = try await session.respond(
                to: text,
                generating: AISummary.self
            )
            return response.content.summary
        }
        #endif
        throw AIServiceError.unavailable
    }
}

public enum AIServiceError: Error, LocalizedError {
    case unavailable

    public var errorDescription: String? {
        switch self {
        case .unavailable:
            return "AI summarization is not available on this device."
        }
    }
}
