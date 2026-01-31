//
//  Tab3ViewController.swift
//  UI
//
//  View controller for Tab3 (Items) screen
//

import UIKit
import SwiftUI
import FunViewModel

public final class Tab3ViewController: UIViewController {

    private let viewModel: Tab3ViewModel

    public init(viewModel: Tab3ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUIView(Tab3View(viewModel: viewModel))
    }
}
