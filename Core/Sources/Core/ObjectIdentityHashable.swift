//
//  ObjectIdentityHashable.swift
//  Core
//
//  Protocol for reference types that use object identity for hashing
//

import Foundation

/// Protocol for reference types that use object identity for equality and hashing
/// This is useful for ObservableObject classes that need to be used in collections
public protocol ObjectIdentityHashable: AnyObject, Hashable {}

extension ObjectIdentityHashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
