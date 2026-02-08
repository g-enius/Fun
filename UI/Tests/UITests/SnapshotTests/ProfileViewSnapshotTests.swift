//
//  ProfileViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for ProfileView
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
final class ProfileViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesService(initialFavorites: ["asyncawait", "swiftui"]), for: .favorites)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testProfileView_defaultState() {
        let viewModel = ProfileViewModel(coordinator: nil)

        let view = ProfileView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testProfileView_darkMode() {
        let viewModel = ProfileViewModel(coordinator: nil)

        let view = ProfileView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}
