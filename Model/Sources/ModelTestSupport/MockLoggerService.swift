//
//  MockLoggerService.swift
//  Model
//
//  Mock implementation of LoggerService for testing
//

import FunModel

@MainActor
public final class MockLoggerService: LoggerService {
    public var loggedMessages: [(message: String, level: LogLevel, category: String)] = []

    public init() {}

    public func log(_ message: String, level: LogLevel, category: LogCategory) {
        loggedMessages.append((message, level, category.rawValue))
    }
}
