//
//  HomeViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for HomeView (Home screen)
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
final class HomeViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
        ServiceLocator.shared.register(MockFavoritesService(), for: .favorites)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testHomeView_withCarouselEnabled() {
        let viewModel = HomeViewModel(coordinator: nil)
        viewModel.isCarouselEnabled = true

        let view = HomeView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testHomeView_withCarouselDisabled() {
        let viewModel = HomeViewModel(coordinator: nil)
        viewModel.isCarouselEnabled = false

        let view = HomeView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testHomeView_darkMode() {
        let viewModel = HomeViewModel(coordinator: nil)
        viewModel.isCarouselEnabled = true

        let view = HomeView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
