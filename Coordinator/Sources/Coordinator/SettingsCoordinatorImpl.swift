//
//  SettingsCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Settings tab
//

import UIKit

import FunModel
import FunUI
import FunViewModel

public final class SettingsCoordinatorImpl: BaseCoordinator, SettingsCoordinator {

    override public func start() {
        let viewModel = SettingsViewModel(coordinator: self)
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

}
