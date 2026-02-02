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

    override public init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
    }

    // MARK: - SettingsCoordinator

    public func dismiss() {
        safeDismiss()
    }
}
