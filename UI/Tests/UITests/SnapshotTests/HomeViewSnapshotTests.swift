//
//  HomeViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for HomeView (Home screen)
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
final class HomeViewSnapshotTests: XCTestCase {

    private func makeServiceLocator() -> ServiceLocator {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(MockFeatureToggleService(), for: .featureToggles)
        locator.register(MockFavoritesService(), for: .favorites)
        locator.register(MockToastService(), for: .toast)
        return locator
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testHomeView_withCarouselEnabled() {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())
        viewModel.isCarouselEnabled = true

        let view = HomeView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testHomeView_withCarouselDisabled() {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())
        viewModel.isCarouselEnabled = false

        let view = HomeView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testHomeView_darkMode() {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())
        viewModel.isCarouselEnabled = true

        let view = HomeView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    // MARK: - iPad Tests

    func testHomeView_iPad_portrait() {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())
        viewModel.isCarouselEnabled = true

        let view = HomeView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 1024, height: 1366)

        assertSnapshot(of: hostingController, as: .image(on: .iPadPro12_9), record: recording)
    }

    func testHomeView_iPad_landscape() {
        let viewModel = HomeViewModel(serviceLocator: makeServiceLocator())
        viewModel.isCarouselEnabled = true

        let view = HomeView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 1366, height: 1024)

        assertSnapshot(of: hostingController, as: .image(on: .iPadPro12_9(.landscape)), record: recording)
    }
}
