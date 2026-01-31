//
//  Tab1ViewController.swift
//  UI
//
//  View controller for Tab1 (Home) screen
//

import UIKit
import SwiftUI
import FunViewModel

public final class Tab1ViewController: UIViewController {

    private let viewModel: Tab1ViewModel

    public init(viewModel: Tab1ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUIView(Tab1View(viewModel: viewModel))
    }
}
