//
//  ItemsViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for ItemsView (Items screen with search and filter)
//

import XCTest
import SwiftUI
import Combine
import SnapshotTesting
@testable import FunUI
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

@MainActor
final class ItemsViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testItemsView_defaultState() {
        let viewModel = ItemsViewModel(coordinator: nil)

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testItemsView_withSearchText() {
        let viewModel = ItemsViewModel(coordinator: nil)
        viewModel.searchText = "swift"

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testItemsView_darkMode() {
        let viewModel = ItemsViewModel(coordinator: nil)

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
