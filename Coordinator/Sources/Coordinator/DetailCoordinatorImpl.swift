//
//  DetailCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Detail screen
//

import UIKit
import FunViewModel
import FunModel

public final class DetailCoordinatorImpl: BaseCoordinator, DetailCoordinator {

    // MARK: - Tab Bar

    private weak var tabBarViewModel: HomeTabBarViewModel?

    // MARK: - Initialization

    public init(navigationController: UINavigationController, tabBarViewModel: HomeTabBarViewModel?) {
        self.tabBarViewModel = tabBarViewModel
        super.init(navigationController: navigationController)
    }

    // MARK: - DetailCoordinator

    public func dismiss() {
        safePop()
    }

    public func switchToTab(_ index: Int) {
        tabBarViewModel?.switchToTab(index)
    }

    // share(text:) is inherited from BaseCoordinator
}
