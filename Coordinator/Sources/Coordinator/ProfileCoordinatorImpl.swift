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

    override public init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
    }

    // MARK: - ProfileCoordinator

    public func dismiss() {
        safeDismiss()
    }
}
