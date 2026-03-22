//
//  LoginContent.swift
//  Coordinator
//
//  Wrapper that creates LoginViewModel with login success closure.
//  Lives in Coordinator (not FunUI) because it depends on AppCoordinator.
//

import SwiftUI

import FunUI
import FunViewModel

/// Wrapper that creates LoginViewModel with login success closure
struct LoginContent: View {
    let coordinator: AppCoordinator
    @StateObject private var viewModel: LoginViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: LoginViewModel(session: coordinator.session))
    }

    var body: some View {
        LoginView(viewModel: viewModel)
            .task {
                viewModel.onLoginSuccess = { [weak coordinator] in
                    coordinator?.transitionToMainFlow()
                }
            }
    }
}
