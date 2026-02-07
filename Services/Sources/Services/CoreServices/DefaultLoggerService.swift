//
//  DefaultLoggerService.swift
//  Services
//
//  OSLog-based implementation of LoggerService
//

import Foundation
import OSLog
import FunModel

@MainActor
public final class DefaultLoggerService: LoggerService {

    /// Subsystem identifier (typically bundle ID)
    private let subsystem: String

    /// Default category for logs
    private let defaultCategory: String

    /// Cache of loggers by category (bounded to prevent unbounded growth)
    private static let maxCacheSize = 50
    private var loggers: [String: Logger] = [:]

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.fun.app",
        defaultCategory: String = "general"
    ) {
        self.subsystem = subsystem
        self.defaultCategory = defaultCategory
    }

    // MARK: - LoggerService

    public func log(_ message: String, level: LogLevel, category: LogCategory) {
        let logger = getLogger(for: category.rawValue)

        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .fault:
            logger.fault("\(message, privacy: .public)")
        }
    }

    // MARK: - Private

    private func getLogger(for category: String) -> Logger {
        if let existing = loggers[category] {
            return existing
        }
        if loggers.count >= Self.maxCacheSize {
            loggers.removeAll()
        }
        let logger = Logger(subsystem: subsystem, category: category)
        loggers[category] = logger
        return logger
    }
}
