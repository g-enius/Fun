//
//  BaseCoordinator.swift
//  Coordinator
//
//  Base coordinator class with safe navigation methods
//

import UIKit

// MARK: - Coordinator Protocol

@MainActor
public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

// MARK: - Base Coordinator

@MainActor
open class BaseCoordinator: Coordinator {

    public let navigationController: UINavigationController

    private var isTransitioning: Bool {
        navigationController.transitionCoordinator != nil
    }

    /// Single pending action retried after the current transition completes.
    /// Handles deep links arriving mid-transition without full queue complexity.
    private var pendingAction: (@MainActor () -> Void)?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    open func start() {
        // Override in subclasses
    }

    // MARK: - Safe Navigation Methods

    public func safePush(_ viewController: UIViewController, animated: Bool = true) {
        guard !isTransitioning else {
            scheduleRetry { [weak self] in
                self?.safePush(viewController, animated: animated)
            }
            return
        }

        navigationController.pushViewController(viewController, animated: animated)
    }

    public func safePop(animated: Bool = true, completion: (@MainActor () -> Void)? = nil) {
        guard !isTransitioning else {
            scheduleRetry { [weak self] in
                self?.safePop(animated: animated, completion: completion)
            }
            return
        }
        navigationController.popViewController(animated: animated)
        // UIKit's popViewController has no completion handler.
        // Hook into the transition coordinator created by the pop to
        // fire our completion after the animation finishes.
        if animated, let transitionCoordinator = navigationController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }

    public func safePresent(_ viewController: UIViewController, animated: Bool = true, completion: (@MainActor () -> Void)? = nil) {
        // Walk up to the topmost presented VC so we present from the right level
        var presenter: UIViewController = navigationController
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        presenter.present(viewController, animated: animated, completion: completion)
    }

    public func safeDismiss(animated: Bool = true, completion: (@MainActor () -> Void)? = nil) {
        guard navigationController.presentedViewController != nil else {
            completion?()
            return
        }
        navigationController.dismiss(animated: animated, completion: completion)
    }

    // MARK: - Share

    public func share(text: String) {
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        // iPad support
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = navigationController.view
            popoverController.sourceRect = CGRect(
                x: navigationController.view.bounds.midX,
                y: navigationController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        safePresent(activityViewController)
    }

    // MARK: - Transition Retry

    /// Schedules a single action to execute after the current transition completes.
    /// If a new action arrives before the previous one executes, it replaces it
    /// (latest navigation intent wins).
    private func scheduleRetry(_ action: @escaping @MainActor () -> Void) {
        pendingAction = action

        if let coordinator = navigationController.transitionCoordinator {
            coordinator.animate(
                alongsideTransition: nil,
                completion: { [weak self] _ in
                    self?.executePendingAction()
                }
            )
        } else {
            executePendingAction()
        }
    }

    private func executePendingAction() {
        let action = pendingAction
        pendingAction = nil
        action?()
    }
}
