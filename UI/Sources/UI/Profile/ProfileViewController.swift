//
//  ProfileViewController.swift
//  UI
//
//  View controller for Profile screen (modal)
//

import UIKit
import SwiftUI
import FunViewModel

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

    public override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUIView(ProfileView(viewModel: viewModel))
    }
}
