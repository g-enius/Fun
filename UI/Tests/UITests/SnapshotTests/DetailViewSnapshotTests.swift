//
//  DetailViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for DetailView
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
final class DetailViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testDetailView_defaultState() {
        let viewModel = DetailViewModel(item: .asyncAwait, coordinator: nil)

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testDetailView_favorited() {
        let viewModel = DetailViewModel(item: .asyncAwait, coordinator: nil)
        viewModel.isFavorited = true

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testDetailView_darkMode() {
        let viewModel = DetailViewModel(item: .swiftUI, coordinator: nil)

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
