//
//  HomeViewController.swift
//  UI
//
//  View controller for Home screen
//

import UIKit
import SwiftUI
import FunViewModel
import FunCore

public final class HomeViewController: UIViewController {

    private let viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Tabs.home
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityID.Home.profileButton
        navigationItem.rightBarButtonItem?.accessibilityLabel = L10n.Profile.title
        embedSwiftUIView(HomeView(viewModel: viewModel))
    }

    @objc private func profileTapped() {
        viewModel.didTapProfile()
    }
}
