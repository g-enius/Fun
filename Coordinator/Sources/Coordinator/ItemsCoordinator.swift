//
//  ItemsCoordinator.swift
//  Coordinator
//
//  Coordinator for Items tab
//

import UIKit

import FunModel
import FunUI
import FunViewModel

public final class ItemsCoordinator: BaseCoordinator {

    private var isShowingDetail = false

    override public func start() {
        let viewModel = ItemsViewModel()
        viewModel.onShowDetail = { [weak self] item in self?.showDetail(for: item) }

        let viewController = ItemsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Navigation

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
