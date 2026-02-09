//
//  ItemsCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Items tab
//

import UIKit

import FunModel
import FunUI
import FunViewModel

public final class ItemsCoordinatorImpl: BaseCoordinator {

    // MARK: - Child Coordinators

    private var detailCoordinator: DetailCoordinatorImpl?

    override public func start() {
        let viewModel = ItemsViewModel(coordinator: self)
        let viewController = ItemsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: - ItemsCoordinator

extension ItemsCoordinatorImpl: ItemsCoordinator {

    public func showDetail(for item: FeaturedItem) {
        guard detailCoordinator == nil else { return }

        let coordinator = DetailCoordinatorImpl(
            navigationController: navigationController
        )
        coordinator.onPop = { [weak self] in
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
}
