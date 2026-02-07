//
//  MockLoginCoordinator.swift
//  Model
//
//  Mock implementation of LoginCoordinator for testing
//

import FunModel

@MainActor
public final class MockLoginCoordinator: LoginCoordinator {

    public var didLoginCalled = false
    public var didLoginCallCount = 0

    public init() {}

    public func didLogin() {
        didLoginCalled = true
        didLoginCallCount += 1
    }
}
