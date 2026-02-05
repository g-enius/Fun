//
//  ItemsViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for ItemsView (Items screen with search and filter)
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
final class ItemsViewSnapshotTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        ServiceLocator.shared.register(MockLoggerServiceForItems(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesServiceForItems(), for: .favorites)
        ServiceLocator.shared.register(MockFeatureToggleServiceForItems(), for: .featureToggles)
    }

    // Set to true to regenerate snapshots, then set back to false
    private var recording: Bool { false }

    func testItemsView_defaultState() {
        let viewModel = ItemsViewModel(coordinator: nil)

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testItemsView_withSearchText() {
        let viewModel = ItemsViewModel(coordinator: nil)
        viewModel.searchText = "swift"

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }

    func testItemsView_darkMode() {
        let viewModel = ItemsViewModel(coordinator: nil)

        let view = ItemsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro), record: recording)
    }
}

// MARK: - Mock Services for Testing

@MainActor
private class MockLoggerServiceForItems: LoggerService {
    func log(_ message: String) {}
    func log(_ message: String, level: LogLevel) {}
    func log(_ message: String, level: LogLevel, category: LogCategory) {}
    func log(_ message: String, level: LogLevel, category: String) {}
}

@MainActor
private class MockFavoritesServiceForItems: FavoritesServiceProtocol {
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
private class MockFeatureToggleServiceForItems: FeatureToggleServiceProtocol {
    var featuredCarousel: Bool = true
    var simulateErrors: Bool = false

    var featureTogglesDidChange: AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }
}
