//
//  BaseViewController.swift
//  UI
//
//  Base view controller with common functionality
//

import UIKit

@MainActor
open class BaseViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
