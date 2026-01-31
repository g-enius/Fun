//
//  Tab2ViewController.swift
//  UI
//
//  View controller for Tab2 (Search) screen
//

import UIKit
import SwiftUI
import FunViewModel

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

    public override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUIView(Tab2View(viewModel: viewModel))
    }
}
