//
//  HomeTabBarViewModelTests.swift
//  ViewModel
//
//  Unit tests for HomeTabBarViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

@Suite("HomeTabBarViewModel Tests", .serialized)
@MainActor
struct HomeTabBarViewModelTests {

    // MARK: - Setup

    init() {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // MARK: - Initialization Tests

    @Test("Initial selectedTabIndex is 0")
    func testInitialTabIndex() async {
        let viewModel = HomeTabBarViewModel()

        #expect(viewModel.selectedTabIndex == 0)
    }

    // MARK: - Tab Change Tests

    @Test("tabDidChange updates selectedTabIndex")
    func testTabDidChangeUpdatesIndex() async {
        let viewModel = HomeTabBarViewModel()

        viewModel.tabDidChange(to: 1)
        #expect(viewModel.selectedTabIndex == 1)

        viewModel.tabDidChange(to: 2)
        #expect(viewModel.selectedTabIndex == 2)

        viewModel.tabDidChange(to: 0)
        #expect(viewModel.selectedTabIndex == 0)
    }

    @Test("switchToTab updates selectedTabIndex")
    func testSwitchToTabUpdatesIndex() async {
        let viewModel = HomeTabBarViewModel()

        viewModel.switchToTab(1)
        #expect(viewModel.selectedTabIndex == 1)

        viewModel.switchToTab(2)
        #expect(viewModel.selectedTabIndex == 2)
    }

    @Test("switchToTab and tabDidChange produce same result")
    func testSwitchAndDidChangeEquivalent() async {
        let vm1 = HomeTabBarViewModel()
        let vm2 = HomeTabBarViewModel()

        vm1.switchToTab(2)
        vm2.tabDidChange(to: 2)

        #expect(vm1.selectedTabIndex == vm2.selectedTabIndex)
    }

    // MARK: - Bounds Checking Tests

    @Test("switchToTab ignores negative index")
    func testSwitchToTabIgnoresNegativeIndex() async {
        let viewModel = HomeTabBarViewModel()

        viewModel.switchToTab(1)
        #expect(viewModel.selectedTabIndex == 1)

        viewModel.switchToTab(-1)
        #expect(viewModel.selectedTabIndex == 1) // Unchanged
    }

    @Test("switchToTab ignores out-of-bounds index")
    func testSwitchToTabIgnoresOutOfBoundsIndex() async {
        let viewModel = HomeTabBarViewModel()

        viewModel.switchToTab(1)
        #expect(viewModel.selectedTabIndex == 1)

        viewModel.switchToTab(99)
        #expect(viewModel.selectedTabIndex == 1) // Unchanged
    }

    @Test("switchToTab accepts all valid tab indices")
    func testSwitchToTabAcceptsAllValidIndices() async {
        let viewModel = HomeTabBarViewModel()

        for tabIndex in TabIndex.allCases {
            viewModel.switchToTab(tabIndex.rawValue)
            #expect(viewModel.selectedTabIndex == tabIndex.rawValue)
        }
    }

}
