//
//  MockTabCoordinator.swift
//  Model
//
//  Mock coordinator for testing ViewModels
//

import Foundation
import FunModel

@MainActor
public final class MockTabCoordinator: HomeCoordinator, ItemsCoordinator {
    public var showDetailCalled = false
    public var showDetailFeaturedItem: FeaturedItem?
    public var showProfileCalled = false

    public init() {}

    // HomeCoordinator & ItemsCoordinator (FeaturedItem)
    public func showDetail(for item: FeaturedItem) {
        showDetailCalled = true
        showDetailFeaturedItem = item
    }

    // HomeCoordinator
    public func showProfile() {
        showProfileCalled = true
    }
}
