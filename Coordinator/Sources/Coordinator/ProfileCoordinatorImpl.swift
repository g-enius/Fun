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
        safeDismiss()
    }
}
