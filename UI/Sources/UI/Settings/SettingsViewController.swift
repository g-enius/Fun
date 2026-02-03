//
//  SettingsViewController.swift
//  UI
//
//  View controller for Settings screen
//

import UIKit
import SwiftUI
import FunViewModel
import FunCore

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

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Tabs.settings
        embedSwiftUIView(SettingsView(viewModel: viewModel))
    }
}
