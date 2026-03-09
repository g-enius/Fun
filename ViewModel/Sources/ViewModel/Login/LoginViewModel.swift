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

    // MARK: - Navigation Closures

    public var onLogin: (() -> Void)?

    // MARK: - Services

    private let logger: LoggerService
    private let networkService: NetworkServiceProtocol
    private let toastService: ToastServiceProtocol

    // MARK: - Published State

    @Published public var isLoggingIn: Bool = false

    // MARK: - Private Properties

    private var loginTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(serviceLocator: ServiceLocator = .shared) {
        self.logger = serviceLocator.resolve(for: .logger)
        self.networkService = serviceLocator.resolve(for: .network)
        self.toastService = serviceLocator.resolve(for: .toast)
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
                self.onLogin?()
            } catch {
                self.logger.log("Login failed: \(error)", level: .error, category: .general)
                self.toastService.showToast(message: L10n.Error.networkError, type: .error)
            }
        }
    }
}
