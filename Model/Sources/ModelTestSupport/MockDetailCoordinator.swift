//
//  MockDetailCoordinator.swift
//  Model
//
//  Mock implementation of DetailCoordinator for testing
//

import FunModel

@MainActor
public final class MockDetailCoordinator: DetailCoordinator {

    public var dismissCalled = false
    public var handleSystemDismissCalled = false
    public var shareCalled = false
    public var lastShareText: String?

    public init() {}

    public func dismiss() {
        dismissCalled = true
    }

    public func handleSystemDismiss() {
        handleSystemDismissCalled = true
    }

    public func share(text: String) {
        shareCalled = true
        lastShareText = text
    }
}
