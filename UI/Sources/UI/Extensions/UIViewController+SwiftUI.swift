//
//  UIViewController+SwiftUI.swift
//  UI
//
//  Extension to embed SwiftUI views in UIViewControllers
//

import UIKit
import SwiftUI

public extension UIViewController {
    /// Embeds a SwiftUI view as a child view controller, filling the entire view
    /// - Parameter content: The SwiftUI view to embed
    func embedSwiftUIView<Content: View>(_ content: Content) {
        let hostingController = UIHostingController(rootView: content)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
