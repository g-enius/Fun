//
//  AppError.swift
//  Model
//
//  App-wide error types
//

import Foundation

import FunCore

public enum AppError: LocalizedError, Equatable, Sendable {
    case networkError

    public var errorDescription: String? {
        switch self {
        case .networkError:
            return L10n.Error.networkError
        }
    }
}
