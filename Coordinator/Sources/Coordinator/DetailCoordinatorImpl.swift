//
//  DetailCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Detail screen
//

import UIKit

import FunModel

public final class DetailCoordinatorImpl: BaseCoordinator {

    /// Callback to notify parent coordinator when detail is popped from navigation stack
    public var onPop: (() -> Void)?
}

// MARK: - DetailCoordinator

extension DetailCoordinatorImpl: DetailCoordinator {

    public func didPop() {
        onPop?()
    }

    // share(text:) is inherited from BaseCoordinator
}
