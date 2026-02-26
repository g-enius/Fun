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

    private var isShowingDetail = false

    override public func start() {
        let viewModel = HomeViewModel(coordinator: self)
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: - HomeCoordinator

extension HomeCoordinatorImpl: HomeCoordinator {

    public func showDetail(for item: FeaturedItem) {
        guard !isShowingDetail else { return }
        isShowingDetail = true

        let viewModel = DetailViewModel(item: item)
        viewModel.onPop = { [weak self] in self?.isShowingDetail = false }
        viewModel.onShare = { [weak self] text in self?.share(text: text) }

        let viewController = DetailViewController(viewModel: viewModel)
        safePush(viewController)
    }

    public func showProfile() {
        let profileNavController = UINavigationController()

        let viewModel = ProfileViewModel()
        viewModel.onDismiss = { [weak self] in self?.safeDismiss() }
        viewModel.onLogout = { [weak self] in self?.safeDismiss { self?.onLogout?() } }
        viewModel.onGoToItems = { [weak self] in
            self?.safeDismiss()
            if let url = URL(string: "funapp://tab/items") {
                UIApplication.shared.open(url)
            }
        }

        let viewController = ProfileViewController(viewModel: viewModel)
        profileNavController.setViewControllers([viewController], animated: false)

        safePresent(profileNavController)
    }
}
