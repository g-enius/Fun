//
//  LoginCoordinator.swift
//  Coordinator
//
//  Coordinator for Login flow
//

import UIKit

import FunCore
import FunUI
import FunViewModel

public final class LoginCoordinator: BaseCoordinator {

    // MARK: - Properties

    private let serviceLocator: ServiceLocator

    /// Callback to notify parent coordinator of successful login
    public var onLoginSuccess: (() -> Void)?

    public init(navigationController: UINavigationController, serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
        super.init(navigationController: navigationController)
    }

    override public func start() {
        let viewModel = LoginViewModel(serviceLocator: serviceLocator)
        viewModel.onLogin = { [weak self] in self?.onLoginSuccess?() }

        let viewController = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
