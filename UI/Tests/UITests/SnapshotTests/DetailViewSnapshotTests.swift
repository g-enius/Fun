//
//  DetailViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for DetailView
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
final class DetailViewSnapshotTests: XCTestCase {

    private func makeSession() -> MockSession {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(MockFavoritesService(), for: .favorites)
        locator.register(MockFeatureToggleService(), for: .featureToggles)
        locator.register(MockAIService(isAvailable: false), for: .ai)
        locator.register(MockToastService(), for: .toast)
        return MockSession(serviceLocator: locator)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testDetailView_defaultState() {
        let viewModel = DetailViewModel(item: .asyncAwait, session: makeSession())

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testDetailView_favorited() {
        let viewModel = DetailViewModel(item: .asyncAwait, session: makeSession())
        viewModel.isFavorited = true

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testDetailView_darkMode() {
        let viewModel = DetailViewModel(item: .swiftUI, session: makeSession())

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
