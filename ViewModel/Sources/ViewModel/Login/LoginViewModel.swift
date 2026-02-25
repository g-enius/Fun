//
//  LoginViewModel.swift
//  ViewModel
//
//  ViewModel for Login screen
//

import Foundation
import Observation

import FunCore
import FunModel

@MainActor
@Observable
public class LoginViewModel {

    // MARK: - Navigation Closures

    public var onLoginSuccess: (() -> Void)?

    // MARK: - Services

    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored @Service(.network) private var networkService: NetworkService

    // MARK: - State

    public var isLoggingIn: Bool = false

    // MARK: - Private Properties

    @ObservationIgnored private var loginTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(onLoginSuccess: (() -> Void)? = nil) {
        self.onLoginSuccess = onLoginSuccess
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
            self.onLoginSuccess?()
        }
    }
}
