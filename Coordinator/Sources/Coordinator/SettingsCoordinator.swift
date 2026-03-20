//
//  SettingsCoordinator.swift
//  Coordinator
//
//  Coordinator for Settings tab
//

import UIKit

import FunCore
import FunUI
import FunViewModel

public final class SettingsCoordinator: BaseCoordinator {

    private let serviceLocator: ServiceLocator

    public init(navigationController: UINavigationController, serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
        super.init(navigationController: navigationController)
    }

    override public func start() {
        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
