//
//  ProfileViewController.swift
//  UI
//
//  View controller for Profile screen (modal)
//

import UIKit
import SwiftUI
import FunViewModel
import FunCore

public final class ProfileViewController: UIViewController {

    private let viewModel: ProfileViewModel

    public init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Profile.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissTapped)
        )
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityID.Profile.dismissButton
        embedSwiftUIView(ProfileView(viewModel: viewModel))
    }

    @objc private func dismissTapped() {
        viewModel.didTapDismiss()
    }
}
