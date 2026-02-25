//
//  ProfileViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for ProfileView
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
final class ProfileViewSnapshotTests: XCTestCase {

    private func makeSession() -> MockSession {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(MockFavoritesService(initialFavorites: ["asyncawait", "swiftui"]), for: .favorites)
        return MockSession(serviceLocator: locator)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testProfileView_defaultState() {
        let viewModel = ProfileViewModel(session: makeSession())

        let view = ProfileView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testProfileView_darkMode() {
        let viewModel = ProfileViewModel(session: makeSession())

        let view = ProfileView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
