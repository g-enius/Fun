//
//  MockSession.swift
//  Model
//
//  Mock session for testing — wraps a pre-configured ServiceLocator
//

import FunCore

@MainActor
public final class MockSession: Session {

    public let serviceLocator: ServiceLocator

    public init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    public func activate() {}
    public func teardown() {}
}
