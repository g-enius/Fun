//
//  AppError.swift
//  Model
//
//  App-wide error types
//

import Foundation
import FunCore

public enum AppError: LocalizedError, Equatable {
    case networkError
    case serverError
    case unknown

    public var errorDescription: String? {
        switch self {
        case .networkError:
            return L10n.Error.networkError
        case .serverError:
            return L10n.Error.serverError
        case .unknown:
            return L10n.Error.unknownError
        }
    }
}
