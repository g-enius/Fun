//
//  ItemsViewController.swift
//  UI
//
//  View controller for Items screen
//

import UIKit
import SwiftUI
import FunViewModel
import FunCore

public final class ItemsViewController: UIViewController {

    private let viewModel: ItemsViewModel

    public init(viewModel: ItemsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Tabs.items
        embedSwiftUIView(ItemsView(viewModel: viewModel))
    }
}
