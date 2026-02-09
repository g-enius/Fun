//
//  MockDetailCoordinator.swift
//  Model
//
//  Mock implementation of DetailCoordinator for testing
//

import FunModel

@MainActor
public final class MockDetailCoordinator: DetailCoordinator {

    public var didPopCalled = false
    public var shareCalled = false
    public var lastShareText: String?

    public init() {}

    public func didPop() {
        didPopCalled = true
    }

    public func share(text: String) {
        shareCalled = true
        lastShareText = text
    }
}
