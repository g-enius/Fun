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

    private let session: Session

    public init(navigationController: UINavigationController, session: Session) {
        self.session = session
        super.init(navigationController: navigationController)
    }

    override public func start() {
        let viewModel = SettingsViewModel(session: session)
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
