//
//  SettingsCoordinator.swift
//  Coordinator
//
//  Coordinator for Settings tab
//

import UIKit

import FunUI
import FunViewModel

public final class SettingsCoordinator: BaseCoordinator {

    override public func start() {
        let viewModel = SettingsViewModel()
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
