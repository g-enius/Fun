//
//  Tab5ViewController.swift
//  UI
//
//  View controller for Tab5 (Settings) screen
//

import UIKit
import SwiftUI
import FunViewModel
import FunModel

public final class Tab5ViewController: UIViewController {

    private let viewModel: Tab5ViewModel

    public init(viewModel: Tab5ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Tabs.settings
        embedSwiftUIView(Tab5View(viewModel: viewModel))
    }
}
