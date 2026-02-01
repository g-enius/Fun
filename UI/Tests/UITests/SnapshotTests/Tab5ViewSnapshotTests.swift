//
//  Tab5ViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for Tab5View (Settings screen)
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import FunUI
@testable import FunViewModel
@testable import FunModel
@testable import FunToolbox

final class Tab5ViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        registerMockServices()
    }

    private func registerMockServices() {
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFeatureToggleServiceForSettings(), for: .featureToggles)
    }

    @MainActor
    func testTab5View_defaultState() {
        let viewModel = Tab5ViewModel(coordinator: nil)

        let view = Tab5View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab5View_darkModeEnabled() {
        let viewModel = Tab5ViewModel(coordinator: nil)
        viewModel.isDarkModeEnabled = true

        let view = Tab5View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab5View_allTogglesEnabled() {
        let viewModel = Tab5ViewModel(coordinator: nil)
        viewModel.isDarkModeEnabled = true
        viewModel.featuredCarouselEnabled = true
        viewModel.analyticsEnabled = true
        viewModel.debugModeEnabled = true

        let view = Tab5View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab5View_allTogglesDisabled() {
        let viewModel = Tab5ViewModel(coordinator: nil)
        viewModel.isDarkModeEnabled = false
        viewModel.featuredCarouselEnabled = false
        viewModel.analyticsEnabled = false
        viewModel.debugModeEnabled = false

        let view = Tab5View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }
}

// MARK: - Mock Services for Testing

@MainActor
private class MockFeatureToggleServiceForSettings: FeatureToggleServiceProtocol {
    var featuredCarousel: Bool = true
    var featureAnalytics: Bool = false
    var featureDebugMode: Bool = false
}
