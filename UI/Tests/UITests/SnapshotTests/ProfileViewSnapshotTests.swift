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

@MainActor
final class ProfileViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        ServiceLocator.shared.register(MockLoggerServiceForProfile(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesServiceForProfile(), for: .favorites)
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

// MARK: - Mock Services for Testing

@MainActor
private class MockLoggerServiceForProfile: LoggerService {
    func log(_ message: String) {}
    func log(_ message: String, level: LogLevel) {}
    func log(_ message: String, level: LogLevel, category: LogCategory) {}
    func log(_ message: String, level: LogLevel, category: String) {}
}

@MainActor
private class MockFavoritesServiceForProfile: FavoritesServiceProtocol {
    var favorites: Set<String> = ["asyncawait", "swiftui"]
    var favoritesDidChange: AnyPublisher<Set<String>, Never> {
        Just(favorites).eraseToAnyPublisher()
    }

    func addFavorite(_ id: String) { favorites.insert(id) }
    func removeFavorite(_ id: String) { favorites.remove(id) }
    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }
    func toggleFavorite(_ id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
    }
}
