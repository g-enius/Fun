//
//  Tab5CoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Tab5 (Settings tab)
//

import UIKit
import FunViewModel
import FunModel
import FunUI

public final class Tab5CoordinatorImpl: BaseCoordinator, Tab5Coordinator {

    // MARK: - Initialization

    override public init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
    }

    override public func start() {
        let viewModel = Tab5ViewModel(coordinator: self)
        let viewController = Tab5ViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Tab5Coordinator

    public func dismiss() {
        safePop()
    }
}
