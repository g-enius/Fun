//
//  HomeCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Home tab
//

import UIKit

import FunModel
import FunUI
import FunViewModel

public final class HomeCoordinatorImpl: BaseCoordinator {

    // MARK: - Properties

    /// Callback to notify parent coordinator of logout
    public var onLogout: (() -> Void)?

    // MARK: - Child Coordinators

    // Store to prevent deallocation, ViewModels hold weak refs
    private var detailCoordinator: DetailCoordinatorImpl?
    private var profileCoordinator: ProfileCoordinatorImpl?
    private var dismissHandler: PresentationDismissHandler?

    override public func start() {
        let viewModel = HomeViewModel(coordinator: self)
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: - HomeCoordinator

extension HomeCoordinatorImpl: HomeCoordinator {

    public func showDetail(for item: FeaturedItem) {
        let coordinator = DetailCoordinatorImpl(
            navigationController: navigationController
        )
        coordinator.onDismiss = { [weak self] in
            self?.detailCoordinator = nil
        }
        detailCoordinator = coordinator

        let viewModel = DetailViewModel(
            item: item,
            coordinator: coordinator
        )
        let viewController = DetailViewController(viewModel: viewModel)
        safePush(viewController)
    }

    public func showProfile() {
        let profileNavController = UINavigationController()
        let coordinator = ProfileCoordinatorImpl(navigationController: profileNavController)
        coordinator.onDismiss = { [weak self] in
            self?.profileCoordinator = nil
        }
        coordinator.onLogout = { [weak self] in
            self?.profileCoordinator = nil
            self?.onLogout?()
        }
        profileCoordinator = coordinator

        let viewModel = ProfileViewModel(coordinator: coordinator)
        let viewController = ProfileViewController(viewModel: viewModel)
        profileNavController.setViewControllers([viewController], animated: false)

        let dismissHandler = PresentationDismissHandler { [weak self] in
            self?.profileCoordinator = nil
            self?.dismissHandler = nil
        }
        profileNavController.presentationController?.delegate = dismissHandler
        self.dismissHandler = dismissHandler

        safePresent(profileNavController)
    }
}

// MARK: - Presentation Dismiss Handler

/// Bridges UIAdaptivePresentationControllerDelegate to a closure (requires NSObject inheritance).
private final class PresentationDismissHandler: NSObject, UIAdaptivePresentationControllerDelegate {
    private let onDismiss: @MainActor () -> Void

    init(onDismiss: @escaping @MainActor () -> Void) {
        self.onDismiss = onDismiss
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        Task { @MainActor in
            onDismiss()
        }
    }
}
