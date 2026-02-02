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

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.itemTitle
        embedSwiftUIView(DetailView(viewModel: viewModel))
    }
}
