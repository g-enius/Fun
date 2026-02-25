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
public class LoginViewModel: ObservableObject, SessionProvider {

    // MARK: - Navigation Closures

    public var onLoginSuccess: (() -> Void)?

    // MARK: - DI

    public let session: Session
    @Service(.logger) private var logger: LoggerService
    @Service(.network) private var networkService: NetworkServiceProtocol
    @Service(.toast) private var toastService: ToastServiceProtocol

    // MARK: - Published State

    @Published public var isLoggingIn: Bool = false

    // MARK: - Private Properties

    private var loginTask: Task<Void, Never>?

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
