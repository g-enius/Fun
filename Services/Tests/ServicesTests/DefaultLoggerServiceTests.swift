//
//  DefaultLoggerServiceTests.swift
//  Services
//
//  Unit tests for DefaultLoggerService
//

import Testing
import Foundation
@testable import FunServices
@testable import FunModel

@Suite("DefaultLoggerService Tests")
@MainActor
struct DefaultLoggerServiceTests {

    // MARK: - Initialization Tests

    @Test("Service initializes with default parameters")
    func testDefaultInit() {
        let service = DefaultLoggerService()
        // Smoke test — should not crash
        service.log("Test message", level: .info, category: .general)
    }

    @Test("Service initializes with custom subsystem and category")
    func testCustomInit() {
        let service = DefaultLoggerService(
            subsystem: "com.test.custom",
            defaultCategory: "custom"
        )
        // Smoke test — should not crash
        service.log("Custom test", level: .debug, category: .general)
    }

    // MARK: - Log Level Tests

    @Test("Logging with all log levels does not crash",
          arguments: [LogLevel.debug, .info, .warning, .error, .fault])
    func testAllLogLevels(level: LogLevel) {
        let service = DefaultLoggerService(subsystem: "com.test.levels")
        service.log("Test \(level)", level: level, category: .general)
    }

    // MARK: - Category Tests

    @Test("Logging with all categories does not crash",
          arguments: [
            LogCategory.general, .network, .ui, .data,
            .navigation, .favorites, .settings, .error
          ])
    func testAllCategories(category: LogCategory) {
        let service = DefaultLoggerService(subsystem: "com.test.categories")
        service.log("Test \(category.rawValue)", level: .info, category: category)
    }

    // MARK: - Protocol Extension Convenience Tests

    @Test("log(_ message:) convenience method works")
    func testLogMessageOnly() {
        let service = DefaultLoggerService(subsystem: "com.test.convenience")
        service.log("Simple message")
    }

    @Test("log(_ message:, level:) convenience method works")
    func testLogMessageWithLevel() {
        let service = DefaultLoggerService(subsystem: "com.test.convenience")
        service.log("Warning message", level: .warning)
    }

    // MARK: - Multiple Sequential Logs

    @Test("Multiple sequential logs do not crash")
    func testMultipleLogs() {
        let service = DefaultLoggerService(subsystem: "com.test.multiple")

        for i in 0..<100 {
            service.log("Message \(i)", level: .info, category: .general)
        }
    }

    @Test("Logging across different categories in sequence works")
    func testCrossCategoryLogs() {
        let service = DefaultLoggerService(subsystem: "com.test.cross")

        service.log("Network request", level: .info, category: .network)
        service.log("UI update", level: .debug, category: .ui)
        service.log("Data saved", level: .info, category: .data)
        service.log("Navigation push", level: .debug, category: .navigation)
        service.log("Favorite toggled", level: .info, category: .favorites)
        service.log("Settings changed", level: .info, category: .settings)
        service.log("An error occurred", level: .error, category: .error)
    }
}
