//
//  LoggerService.swift
//  Model
//
//  Protocol for logging service using OSLog
//

import Foundation
import OSLog

/// Log levels matching OSLog types
public enum LogLevel: Sendable {
    case debug
    case info
    case warning
    case error
    case fault

    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .fault: return .fault
        }
    }
}

/// Log categories for type-safe logging
public enum LogCategory: String, Sendable {
    case general
    case network
    case ui
    case data
    case navigation
    case favorites
    case settings
    case error
}

/// Protocol for structured logging
@MainActor
public protocol LoggerService {
    func log(_ message: String, level: LogLevel, category: LogCategory)
}

extension LoggerService {
    public func log(_ message: String) {
        log(message, level: .info, category: .general)
    }

    public func log(_ message: String, level: LogLevel) {
        log(message, level: level, category: .general)
    }
}
