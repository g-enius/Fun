//
//  ItemsCoordinator.swift
//  Coordinator
//
//  Coordinator for Items tab
//

import UIKit

import FunCore
import FunModel
import FunUI
import FunViewModel

public final class ItemsCoordinator: BaseCoordinator {

    private let session: Session
    private var isShowingDetail = false

    public init(navigationController: UINavigationController, session: Session) {
        self.session = session
        super.init(navigationController: navigationController)
    }

    override public func start() {
        let viewModel = ItemsViewModel(session: session)
        viewModel.onShowDetail = { [weak self] item in self?.showDetail(for: item) }

        let viewController = ItemsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Navigation

    public func showDetail(for item: FeaturedItem) {
        guard !isShowingDetail else { return }
        isShowingDetail = true

        let viewModel = DetailViewModel(item: item, session: session)
        viewModel.onPop = { [weak self] in self?.isShowingDetail = false }
        viewModel.onShare = { [weak self] text in self?.share(text: text) }

        let viewController = DetailViewController(viewModel: viewModel)
        safePush(viewController)
    }
}
