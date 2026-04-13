//
//  SettingsViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for SettingsView (Settings screen)
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
final class SettingsViewSnapshotTests: XCTestCase {

    private func makeSession() -> MockSession {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(MockFeatureToggleService(), for: .featureToggles)
        return MockSession(serviceLocator: locator)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testSettingsView_defaultState() {
        let viewModel = SettingsViewModel(session: makeSession())

        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testSettingsView_darkAppearance() {
        let viewModel = SettingsViewModel(session: makeSession())
        viewModel.appearanceMode = .dark

        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testSettingsView_carouselEnabled() {
        let viewModel = SettingsViewModel(session: makeSession())
        viewModel.featuredCarouselEnabled = true

        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testSettingsView_carouselDisabled() {
        let viewModel = SettingsViewModel(session: makeSession())
        viewModel.featuredCarouselEnabled = false

        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
