//
//  LoginViewModel.swift
//  ViewModel
//
//  ViewModel for Login screen
//

import Combine
import Foundation

import FunCore
import FunModel

@MainActor
public class LoginViewModel: ObservableObject {

    // MARK: - Coordinator

    private weak var coordinator: LoginCoordinator?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService

    // MARK: - Published State

    @Published public var isLoggingIn: Bool = false

    // MARK: - Private Properties

    private var loginTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(coordinator: LoginCoordinator?) {
        self.coordinator = coordinator
    }

    deinit {
        loginTask?.cancel()
    }

    // MARK: - Actions

    public func login() {
        guard !isLoggingIn else { return }

        isLoggingIn = true
        logger.log("User tapped login", level: .info, category: .general)

        // Simulate a brief login delay for realism
        loginTask?.cancel()
        loginTask = Task { [weak self] in
            defer { self?.isLoggingIn = false }
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            self?.coordinator?.didLogin()
        }
    }
}
