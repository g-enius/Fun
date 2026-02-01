//
//  Tab1ViewSnapshotTests.swift
//  UI
//
//  Snapshot tests for Tab1View (Home screen)
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import FunUI
@testable import FunViewModel
@testable import FunModel
@testable import FunToolbox

final class Tab1ViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Register mock services for testing
        registerMockServices()
    }

    private func registerMockServices() {
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFeatureToggleService(), for: .featureToggles)
    }

    @MainActor
    func testTab1View_withCarouselEnabled() {
        let viewModel = Tab1ViewModel(coordinator: nil, tabBarViewModel: nil)
        viewModel.isCarouselEnabled = true

        let view = Tab1View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab1View_withCarouselDisabled() {
        let viewModel = Tab1ViewModel(coordinator: nil, tabBarViewModel: nil)
        viewModel.isCarouselEnabled = false

        let view = Tab1View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }

    @MainActor
    func testTab1View_darkMode() {
        let viewModel = Tab1ViewModel(coordinator: nil, tabBarViewModel: nil)
        viewModel.isCarouselEnabled = true

        let view = Tab1View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = .dark
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(of: hostingController, as: .image(on: .iPhone13Pro))
    }
}

// MARK: - Mock Services for Testing

@MainActor
private class MockFeatureToggleService: FeatureToggleServiceProtocol {
    var featuredCarousel: Bool = true
    var featureAnalytics: Bool = false
    var featureDebugMode: Bool = false
}
