//
//  ProfileCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Profile screen (modal)
//

import UIKit
import FunViewModel
import FunModel

public final class ProfileCoordinatorImpl: BaseCoordinator, ProfileCoordinator {

    // MARK: - Tab Bar

    private weak var tabBarViewModel: HomeTabBarViewModel?

    // MARK: - Initialization

    public init(navigationController: UINavigationController, tabBarViewModel: HomeTabBarViewModel?) {
        self.tabBarViewModel = tabBarViewModel
        super.init(navigationController: navigationController)
    }

    // MARK: - ProfileCoordinator

    public func dismiss() {
        // The navigationController IS the presented modal, so dismiss it directly
        navigationController.dismiss(animated: true)
    }

    public func dismissAndSwitchToItems() {
        // First dismiss the profile modal, then switch to Items tab
        navigationController.dismiss(animated: true) { [weak self] in
            self?.tabBarViewModel?.switchToTab(1) // Items tab is now index 1
        }
    }
}
