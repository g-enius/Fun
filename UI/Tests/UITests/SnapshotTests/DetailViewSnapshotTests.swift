//
//  DetailViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for DetailView
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
final class DetailViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        ServiceLocator.shared.register(MockLoggerServiceForDetail(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesServiceForDetail(), for: .favorites)
        ServiceLocator.shared.register(MockToastServiceForDetail(), for: .toast)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testDetailView_defaultState() {
        let viewModel = DetailViewModel(item: .asyncAwait, coordinator: nil)

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testDetailView_favorited() {
        let viewModel = DetailViewModel(item: .asyncAwait, coordinator: nil)
        viewModel.isFavorite = true

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testDetailView_darkMode() {
        let viewModel = DetailViewModel(item: .swiftUI, coordinator: nil)

        let view = DetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}

// MARK: - Mock Services for Testing

@MainActor
private class MockLoggerServiceForDetail: LoggerService {
    func log(_ message: String) {}
    func log(_ message: String, level: LogLevel) {}
    func log(_ message: String, level: LogLevel, category: LogCategory) {}
    func log(_ message: String, level: LogLevel, category: String) {}
}

@MainActor
private class MockFavoritesServiceForDetail: FavoritesServiceProtocol {
    var favorites: Set<String> = []
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

@MainActor
private class MockToastServiceForDetail: ToastServiceProtocol {
    var toastPublisher: AnyPublisher<ToastEvent, Never> {
        Empty().eraseToAnyPublisher()
    }

    func showToast(message: String, type: ToastType) {}
}
