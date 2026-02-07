//
//  LoginViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for LoginView
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
final class LoginViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testLoginView_defaultState() {
        let viewModel = LoginViewModel(coordinator: nil)

        let view = LoginView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testLoginView_loggingInState() {
        let viewModel = LoginViewModel(coordinator: nil)
        viewModel.isLoggingIn = true

        let view = LoginView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testLoginView_darkMode() {
        let viewModel = LoginViewModel(coordinator: nil)

        let view = LoginView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}

