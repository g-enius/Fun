//
//  SettingsCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Settings screen (modal)
//

import UIKit
import FunViewModel
import FunModel

public final class SettingsCoordinatorImpl: BaseCoordinator, SettingsCoordinator {

    // MARK: - Tab Bar

    private weak var tabBarViewModel: HomeTabBarViewModel?

    // MARK: - Initialization

    public init(navigationController: UINavigationController, tabBarViewModel: HomeTabBarViewModel?) {
        self.tabBarViewModel = tabBarViewModel
        super.init(navigationController: navigationController)
    }

    // MARK: - SettingsCoordinator

    public func dismiss() {
        safeDismiss()
    }
}
