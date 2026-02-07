//
//  ProfileCoordinatorImpl.swift
//  Coordinator
//
//  Coordinator implementation for Profile screen (modal)
//

import UIKit

import FunModel
import FunViewModel

public final class ProfileCoordinatorImpl: BaseCoordinator, ProfileCoordinator {

    // MARK: - Properties

    /// Callback to notify parent coordinator of logout
    public var onLogout: (() -> Void)?

    /// Callback to notify parent coordinator when dismissed (non-logout)
    public var onDismiss: (() -> Void)?

    // MARK: - State

    private var isDismissed = false

    // MARK: - ProfileCoordinator

    public func dismiss() {
        guard !isDismissed else { return }
        isDismissed = true
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }

    public func logout() {
        guard !isDismissed else { return }
        isDismissed = true
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onLogout?()
        }
    }

    public func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
