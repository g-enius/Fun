//
//  DefaultLoggerService.swift
//  Services
//
//  Default implementation of LoggerService
//

import Foundation
import FunModel

@MainActor
public final class DefaultLoggerService: LoggerService {

    public init() {}

    public func log(_ message: String) {
        print("[LOG] \(message)")
    }

    public func log(_ message: String, level: LogLevel) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(level.rawValue.uppercased())] [\(timestamp)] \(message)")
    }
}
