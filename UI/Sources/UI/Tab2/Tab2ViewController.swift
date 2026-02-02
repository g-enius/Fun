//
//  Tab2ViewController.swift
//  UI
//
//  View controller for Tab2 (Search) screen
//

import UIKit
import SwiftUI
import FunViewModel
import FunModel

public final class Tab2ViewController: UIViewController {

    private let viewModel: Tab2ViewModel

    public init(viewModel: Tab2ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Tabs.search
        embedSwiftUIView(Tab2View(viewModel: viewModel))
    }
}
