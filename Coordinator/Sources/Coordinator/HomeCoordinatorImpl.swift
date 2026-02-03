//
//  HomeCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Home tab
//

import UIKit
import FunViewModel
import FunModel
import FunUI
import FunCore

public final class HomeCoordinatorImpl: BaseCoordinator, HomeCoordinator {

    // MARK: - Services

    @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - Child Coordinators

    // Store to prevent deallocation, ViewModels hold weak refs
    private var detailCoordinator: DetailCoordinatorImpl?
    private var profileCoordinator: ProfileCoordinatorImpl?

    // MARK: - Tab Bar

    private weak var tabBarViewModel: HomeTabBarViewModel?

    // MARK: - Initialization

    public init(navigationController: UINavigationController, tabBarViewModel: HomeTabBarViewModel) {
        self.tabBarViewModel = tabBarViewModel
        super.init(navigationController: navigationController)
    }

    override public func start() {
        let viewModel = HomeViewModel(coordinator: self)
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - HomeCoordinator

    public func showDetail(for item: FeaturedItem) {
        let coordinator = DetailCoordinatorImpl(
            navigationController: navigationController,
            tabBarViewModel: tabBarViewModel
        )
        detailCoordinator = coordinator

        let viewModel = DetailViewModel(
            item: item,
            coordinator: coordinator,
            tabBarViewModel: tabBarViewModel
        )
        let viewController = DetailViewController(viewModel: viewModel)
        safePush(viewController)
    }

    public func showProfile() {
        let profileNavController = UINavigationController()

        // Apply current dark mode setting to modal via service
        let isDarkMode = featureToggleService.darkModeEnabled
        profileNavController.overrideUserInterfaceStyle = isDarkMode ? .dark : .light

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
}
