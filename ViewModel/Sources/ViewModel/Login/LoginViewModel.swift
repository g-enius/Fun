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
    @Service(.network) private var networkService: NetworkService

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

        loginTask?.cancel()
        loginTask = Task { [weak self] in
            guard let self else { return }
            defer { self.isLoggingIn = false }
            try? await self.networkService.login()
            self.coordinator?.didLogin()
        }
    }
}
