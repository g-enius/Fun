//
//  MockHomeCoordinator.swift
//  Model
//
//  Mock coordinator for testing HomeViewModel
//

import FunModel

@MainActor
public final class MockHomeCoordinator: HomeCoordinator {
    public var showDetailCalled = false
    public var showDetailItem: FeaturedItem?
    public var showProfileCalled = false

    public init() {}

    public func showDetail(for item: FeaturedItem) {
        showDetailCalled = true
        showDetailItem = item
    }

    public func showProfile() {
        showProfileCalled = true
    }
}
