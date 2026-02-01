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

    // MARK: - Initialization

    public init(navigationController: UINavigationController, tabBarViewModel _: HomeTabBarViewModel? = nil) {
        super.init(navigationController: navigationController)
    }

    // MARK: - ProfileCoordinator

    public func dismiss() {
        safeDismiss()
    }
}
