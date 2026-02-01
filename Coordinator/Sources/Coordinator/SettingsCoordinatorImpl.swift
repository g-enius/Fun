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

    // MARK: - Initialization

    public init(navigationController: UINavigationController, tabBarViewModel _: HomeTabBarViewModel? = nil) {
        super.init(navigationController: navigationController)
    }

    // MARK: - SettingsCoordinator

    public func dismiss() {
        safeDismiss()
    }
}
