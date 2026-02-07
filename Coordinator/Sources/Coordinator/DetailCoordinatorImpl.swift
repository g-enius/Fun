//
//  DetailCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Detail screen
//

import UIKit

import FunModel

public final class DetailCoordinatorImpl: BaseCoordinator, DetailCoordinator {

    /// Callback to notify parent coordinator when detail is dismissed
    public var onDismiss: (() -> Void)?

    private var isDismissed = false

    // MARK: - DetailCoordinator

    public func dismiss() {
        guard !isDismissed else { return }
        isDismissed = true
        safePop()
        onDismiss?()
    }

    public func handleSystemDismiss() {
        guard !isDismissed else { return }
        isDismissed = true
        onDismiss?()
    }

    // share(text:) is inherited from BaseCoordinator
}
