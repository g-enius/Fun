//
//  ItemsViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for ItemsView (Items screen with search and filter)
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import FunUI
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

@MainActor
final class ItemsViewSnapshotTests: XCTestCase {

    private func makeSession() -> MockSession {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(MockFavoritesService(), for: .favorites)
        locator.register(MockFeatureToggleService(), for: .featureToggles)
        locator.register(MockToastService(), for: .toast)
        return MockSession(serviceLocator: locator)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testItemsView_defaultState() async {
        let viewModel = ItemsViewModel(session: makeSession())
        await viewModel.loadItems()

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testItemsView_withSearchText() async {
        let viewModel = ItemsViewModel(session: makeSession())
        await viewModel.loadItems()
        viewModel.searchText = "swift"

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testItemsView_darkMode() async {
        let viewModel = ItemsViewModel(session: makeSession())
        await viewModel.loadItems()

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
