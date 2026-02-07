//
//  MockLoginCoordinator.swift
//  Model
//
//  Mock implementation of LoginCoordinator for testing
//

import Foundation
import FunModel

@MainActor
public final class MockLoginCoordinator: LoginCoordinator {

    public var didLoginCalled = false

    public init() {}

    public func didLogin() {
        didLoginCalled = true
    }
}
