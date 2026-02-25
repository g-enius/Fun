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
public class LoginViewModel: SessionProvider {

    // MARK: - Navigation Closures

    @ObservationIgnored public var onLoginSuccess: (() -> Void)?

    // MARK: - DI

    public let session: Session
    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored @Service(.network) private var networkService: NetworkServiceProtocol
    @ObservationIgnored @Service(.toast) private var toastService: ToastServiceProtocol

    // MARK: - State

    public var isLoggingIn: Bool = false

    // MARK: - Private Properties

    @ObservationIgnored private var loginTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(session: Session) {
        self.session = session
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
            do {
                try await self.networkService.login()
                self.onLoginSuccess?()
            } catch {
                self.logger.log("Login failed: \(error)", level: .error, category: .general)
                self.toastService.showToast(message: L10n.Error.networkError, type: .error)
            }
        }
    }
}
