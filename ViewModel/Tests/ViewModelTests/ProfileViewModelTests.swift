//
//  ProfileViewModelTests.swift
//  ViewModel
//
//  Unit tests for ProfileViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

@Suite("ProfileViewModel Tests", .serialized)
@MainActor
struct ProfileViewModelTests {

    // MARK: - Setup

    private func setupServices() {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
    }

    // MARK: - Logout Tests

    @Test("Logout calls coordinator logout")
    func testLogoutCallsCoordinator() async {
        setupServices()
        let coordinator = MockProfileCoordinator()
        let viewModel = ProfileViewModel(coordinator: coordinator)

        viewModel.logout()

        #expect(coordinator.logoutCalled == true)
    }
}
