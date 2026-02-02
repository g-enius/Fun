//
//  Tab2CoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Tab2 (Search)
//

import UIKit
import FunViewModel
import FunModel
import FunUI

public final class Tab2CoordinatorImpl: BaseCoordinator, Tab2Coordinator {

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
        let viewModel = Tab2ViewModel(coordinator: self, tabBarViewModel: tabBarViewModel)
        let viewController = Tab2ViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Tab2Coordinator

    public func showDetail(for item: String) {
        let coordinator = DetailCoordinatorImpl(
            navigationController: navigationController,
            tabBarViewModel: tabBarViewModel
        )
        detailCoordinator = coordinator

        let viewModel = DetailViewModel(
            itemTitle: item,
            category: "Search Result",
            coordinator: coordinator,
            tabBarViewModel: tabBarViewModel
        )
        let viewController = DetailViewController(viewModel: viewModel)
        safePush(viewController)
    }

    public func switchToTab(_ index: Int) {
        tabBarViewModel?.switchToTab(index)
    }
}
