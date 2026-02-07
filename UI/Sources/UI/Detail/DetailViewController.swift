//
//  DetailViewController.swift
//  UI
//
//  View controller for Detail screen
//

import Combine
import SwiftUI
import UIKit

import FunViewModel

public final class DetailViewController: UIViewController {

    private let viewModel: DetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private var favoriteButton: UIBarButtonItem?

    public init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel.handleBackNavigation()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.itemTitle
        setupNavigationBar()
        observeFavoriteState()
        embedSwiftUIView(DetailView(viewModel: viewModel))
    }

    private func setupNavigationBar() {
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareTapped)
        )
        shareButton.accessibilityIdentifier = AccessibilityID.Detail.shareButton

        favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: viewModel.isFavorited ? "star.fill" : "star"),
            style: .plain,
            target: self,
            action: #selector(favoriteTapped)
        )
        favoriteButton?.tintColor = viewModel.isFavorited ? .systemYellow : .systemBlue
        favoriteButton?.accessibilityIdentifier = AccessibilityID.Detail.favoriteButton

        navigationItem.rightBarButtonItems = [shareButton, favoriteButton].compactMap { $0 }
    }

    private func observeFavoriteState() {
        viewModel.$isFavorited
            .sink { [weak self] isFavorited in
                self?.updateFavoriteButton(isFavorited: isFavorited)
            }
            .store(in: &cancellables)
    }

    private func updateFavoriteButton(isFavorited: Bool) {
        favoriteButton?.image = UIImage(systemName: isFavorited ? "star.fill" : "star")
        favoriteButton?.tintColor = isFavorited ? .systemYellow : .systemBlue
    }

    @objc private func shareTapped() {
        viewModel.didTapShare()
    }

    @objc private func favoriteTapped() {
        viewModel.didTapToggleFavorite()
    }
}
