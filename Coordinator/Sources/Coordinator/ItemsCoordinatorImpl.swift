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

    private var isShowingDetail = false

    override public func start() {
        let viewModel = ItemsViewModel(coordinator: self)
        let viewController = ItemsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: - ItemsCoordinator

extension ItemsCoordinatorImpl: ItemsCoordinator {

    public func showDetail(for item: FeaturedItem) {
        guard !isShowingDetail else { return }
        isShowingDetail = true

        let viewModel = DetailViewModel(item: item)
        viewModel.onPop = { [weak self] in self?.isShowingDetail = false }
        viewModel.onShare = { [weak self] text in self?.share(text: text) }

        let viewController = DetailViewController(viewModel: viewModel)
        safePush(viewController)
    }
}
