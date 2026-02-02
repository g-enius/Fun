//
//  Tab4ViewController.swift
//  UI
//
//  View controller for Tab4 screen
//

import UIKit
import SwiftUI
import FunViewModel

public final class Tab4ViewController: UIViewController {

    private let viewModel: Tab4ViewModel

    public init(viewModel: Tab4ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        embedSwiftUIView(Tab4View(viewModel: viewModel))
    }
}
