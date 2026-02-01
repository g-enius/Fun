//
//  Tab2ViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for Tab2View (Search screen)
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import FunUI
@testable import FunViewModel
@testable import FunModel
@testable import FunToolbox

final class Tab2ViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        registerMockServices()
    }

    private func registerMockServices() {
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
    }

    @MainActor
    func testTab2View_allCategories() {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        let view = Tab2View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab2View_techCategorySelected() {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)
        viewModel.didSelectCategory("Tech")

        let view = Tab2View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab2View_withSearchText() {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)
        viewModel.searchText = "Swift"
        viewModel.didSelectCategory("All") // Trigger filter

        let view = Tab2View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab2View_noResults() {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)
        viewModel.searchText = "nonexistent"
        viewModel.didSelectCategory("All")

        let view = Tab2View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab2View_darkMode() {
        let viewModel = Tab2ViewModel(coordinator: nil, tabBarViewModel: nil)

        let view = Tab2View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }
}
