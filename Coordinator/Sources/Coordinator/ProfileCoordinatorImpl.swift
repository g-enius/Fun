//
//  ProfileCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Profile screen (modal)
//

import UIKit

import FunModel
import FunViewModel

public final class ProfileCoordinatorImpl: BaseCoordinator {

    // MARK: - Properties

    /// Callback to notify parent coordinator of logout
    public var onLogout: (() -> Void)?

    /// Callback to notify parent coordinator when dismissed (non-logout)
    public var onDismiss: (() -> Void)?
}

// MARK: - ProfileCoordinator

extension ProfileCoordinatorImpl: ProfileCoordinator {

    public func dismiss() {
        safeDismiss { [weak self] in self?.onDismiss?() }
    }

    public func logout() {
        safeDismiss { [weak self] in self?.onLogout?() }
    }

    public func didDismiss() {
        onDismiss?()
    }

    public func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
