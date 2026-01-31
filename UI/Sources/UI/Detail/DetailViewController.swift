//
//  DetailViewController.swift
//  UI
//
//  View controller for Detail screen
//

import UIKit
import SwiftUI
import FunViewModel

public final class DetailViewController: UIViewController {

    private let viewModel: DetailViewModel

    public init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUIView(DetailView(viewModel: viewModel))
    }
}
