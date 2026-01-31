//
//  SettingsViewController.swift
//  UI
//
//  View controller for Settings screen (modal)
//

import UIKit
import SwiftUI
import FunViewModel

public final class SettingsViewController: UIViewController {

    private let viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUIView(SettingsView(viewModel: viewModel))
    }
}
