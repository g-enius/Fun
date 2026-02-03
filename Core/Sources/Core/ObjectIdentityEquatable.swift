//
//  ObjectIdentityEquatable.swift
//  Core
//
//  Protocol for reference types that use object identity for equality
//

import Foundation

/// Protocol for reference types that use object identity for equality
public protocol ObjectIdentityEquatable: AnyObject, Equatable {}

extension ObjectIdentityEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs === rhs
    }
}
