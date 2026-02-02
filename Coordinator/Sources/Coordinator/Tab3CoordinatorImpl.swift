//
//  Tab3CoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Tab3 (Items)
//

import UIKit
import FunViewModel
import FunModel
import FunUI

public final class Tab3CoordinatorImpl: BaseCoordinator, Tab3Coordinator {

    // MARK: - Child Coordinators

    private var detailCoordinator: DetailCoordinatorImpl?

    // MARK: - Tab Bar

    private weak var tabBarViewModel: HomeTabBarViewModel?

    // MARK: - Initialization

    public init(navigationController: UINavigationController, tabBarViewModel: HomeTabBarViewModel) {
        self.tabBarViewModel = tabBarViewModel
        super.init(navigationController: navigationController)
    }

    override public func start() {
        let viewModel = Tab3ViewModel(coordinator: self)
        let viewController = Tab3ViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Tab3Coordinator

    public func showDetail(for item: String) {
        let coordinator = DetailCoordinatorImpl(
            navigationController: navigationController,
            tabBarViewModel: tabBarViewModel
        )
        detailCoordinator = coordinator

        let viewModel = DetailViewModel(
            itemTitle: item,
            category: "List Item",
            coordinator: coordinator,
            tabBarViewModel: tabBarViewModel
        )
        let viewController = DetailViewController(viewModel: viewModel)
        safePush(viewController)
    }
}
