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

    // MARK: - DetailCoordinator

    public func dismiss() {
        safePop()
        onDismiss?()
    }

    // share(text:) is inherited from BaseCoordinator
}
