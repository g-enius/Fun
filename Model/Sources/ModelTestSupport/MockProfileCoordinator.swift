//
//  MockProfileCoordinator.swift
//  Model
//
//  Mock implementation of ProfileCoordinator for testing
//

import Foundation
import FunModel

@MainActor
public final class MockProfileCoordinator: ProfileCoordinator {

    public var dismissCalled = false
    public var logoutCalled = false
    public var openURLCalled = false
    public var lastOpenedURL: URL?

    public init() {}

    public func dismiss() {
        dismissCalled = true
    }

    public func logout() {
        logoutCalled = true
    }

    public func openURL(_ url: URL) {
        openURLCalled = true
        lastOpenedURL = url
    }
}
