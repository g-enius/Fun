//
//  SettingsViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for SettingsView (Settings screen)
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
final class SettingsViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testSettingsView_defaultState() {
        let viewModel = SettingsViewModel(coordinator: nil)

        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testSettingsView_darkModeEnabled() {
        let viewModel = SettingsViewModel(coordinator: nil)
        viewModel.isDarkModeEnabled = true

        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testSettingsView_carouselEnabled() {
        let viewModel = SettingsViewModel(coordinator: nil)
        viewModel.featuredCarouselEnabled = true

        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testSettingsView_carouselDisabled() {
        let viewModel = SettingsViewModel(coordinator: nil)
        viewModel.featuredCarouselEnabled = false

        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
