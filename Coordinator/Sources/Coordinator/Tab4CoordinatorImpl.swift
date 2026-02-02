//
//  Tab4CoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Tab4
//

import UIKit
import FunViewModel
import FunModel
import FunUI

public final class Tab4CoordinatorImpl: BaseCoordinator, Tab4Coordinator {

    // MARK: - Initialization

    override public init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
    }

    override public func start() {
        let viewModel = Tab4ViewModel(coordinator: self)
        let viewController = Tab4ViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Tab4Coordinator

    public func dismiss() {
        safePop()
    }
}
