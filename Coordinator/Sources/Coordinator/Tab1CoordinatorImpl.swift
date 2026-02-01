//
//  Tab1CoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Tab1 (Home)
//

import UIKit
import FunViewModel
import FunModel
import FunUI

public final class Tab1CoordinatorImpl: BaseCoordinator, Tab1Coordinator {

    // MARK: - Child Coordinators

    // Store to prevent deallocation, ViewModels hold weak refs
    private var detailCoordinator: DetailCoordinatorImpl?
    private var settingsCoordinator: SettingsCoordinatorImpl?
    private var profileCoordinator: ProfileCoordinatorImpl?

    // MARK: - Tab Bar

    private weak var tabBarViewModel: HomeTabBarViewModel?

    // MARK: - Initialization

    public init(navigationController: UINavigationController, tabBarViewModel: HomeTabBarViewModel) {
        self.tabBarViewModel = tabBarViewModel
        super.init(navigationController: navigationController)
    }

    public override func start() {
        let viewModel = Tab1ViewModel(coordinator: self, tabBarViewModel: tabBarViewModel)
        let viewController = Tab1ViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Tab1Coordinator

    public func showDetail(for item: String) {
        let coordinator = DetailCoordinatorImpl(
            navigationController: navigationController,
            tabBarViewModel: tabBarViewModel
        )
        detailCoordinator = coordinator

        let viewModel = DetailViewModel(
            itemTitle: item,
            category: "Async Data",
            coordinator: coordinator,
            tabBarViewModel: tabBarViewModel
        )
        let viewController = DetailViewController(viewModel: viewModel)
        safePush(viewController)
    }

    public func showProfile() {
        let profileNavController = UINavigationController()
        let coordinator = ProfileCoordinatorImpl(
            navigationController: profileNavController,
            tabBarViewModel: tabBarViewModel
        )
        profileCoordinator = coordinator

        let viewModel = ProfileViewModel(coordinator: coordinator)
        let viewController = ProfileViewController(viewModel: viewModel)
        profileNavController.setViewControllers([viewController], animated: false)
        safePresent(profileNavController)
    }

    public func showSettings() {
        let settingsNavController = UINavigationController()
        let coordinator = SettingsCoordinatorImpl(
            navigationController: settingsNavController,
            tabBarViewModel: tabBarViewModel
        )
        settingsCoordinator = coordinator

        let viewModel = SettingsViewModel(coordinator: coordinator)
        let viewController = SettingsViewController(viewModel: viewModel)
        settingsNavController.setViewControllers([viewController], animated: false)
        safePresent(settingsNavController)
    }
}
