//
//  BaseCoordinator.swift
//  Coordinator
//
//  Base coordinator class with safe navigation methods
//

import UIKit

import FunCore
import FunModel

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

    @Service(.logger) private var logger: LoggerService

    private var isTransitioning: Bool {
        navigationController.transitionCoordinator != nil
    }

    private var pendingActions: [@MainActor () -> Void] = []
    private var lastPushTime: CFAbsoluteTime = 0
    private static let pushDebounceInterval: CFAbsoluteTime = 0.3

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    open func start() {
        // Override in subclasses
    }

    // MARK: - Safe Navigation Methods

    public func safePush(_ viewController: UIViewController, animated: Bool = true) {
        guard !isTransitioning else {
            queueAction { [weak self] in
                self?.safePush(viewController, animated: animated)
            }
            return
        }

        // Prevent duplicate pushes
        if navigationController.topViewController?.isKind(of: type(of: viewController)) == true {
            logger.log("Attempted to push duplicate screen")
            return
        }

        // Debounce rapid taps
        let now = CFAbsoluteTimeGetCurrent()
        guard now - lastPushTime >= Self.pushDebounceInterval else {
            logger.log("Push debounced — too rapid")
            return
        }
        lastPushTime = now

        navigationController.pushViewController(viewController, animated: animated)
    }

    public func safePop(animated: Bool = true) {
        guard !isTransitioning else {
            queueAction { [weak self] in
                self?.safePop(animated: animated)
            }
            return
        }
        navigationController.popViewController(animated: animated)
    }

    public func safePopToRoot(animated: Bool = true) {
        guard !isTransitioning else {
            queueAction { [weak self] in
                self?.safePopToRoot(animated: animated)
            }
            return
        }
        navigationController.popToRootViewController(animated: animated)
    }

    public func safePresent(_ viewController: UIViewController, animated: Bool = true, completion: (@MainActor () -> Void)? = nil) {
        guard navigationController.presentedViewController == nil else {
            logger.log("Already presenting a view controller")
            return
        }
        navigationController.present(viewController, animated: animated, completion: completion)
    }

    public func safeDismiss(animated: Bool = true, completion: (@MainActor () -> Void)? = nil) {
        guard navigationController.presentedViewController != nil else {
            completion?()
            return
        }
        navigationController.dismiss(animated: animated, completion: completion)
    }

    public func dismiss(usePop: Bool = true, animated: Bool = true, completion: (@MainActor () -> Void)? = nil) {
        if usePop {
            safePop(animated: animated)
            if animated, let transitionCoordinator = navigationController.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: nil) { _ in
                    completion?()
                }
            } else {
                completion?()
            }
        } else {
            safeDismiss(animated: animated, completion: completion)
        }
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

    // MARK: - Action Queue

    private func queueAction(_ action: @escaping @MainActor () -> Void) {
        pendingActions.append(action)

        if pendingActions.count == 1 {
            if let coordinator = navigationController.transitionCoordinator {
                coordinator.animate(
                    alongsideTransition: nil,
                    completion: { [weak self] _ in
                        Task { @MainActor in
                            self?.executeQueuedActions()
                        }
                    }
                )
            } else {
                // Transition already completed; execute immediately
                executeQueuedActions()
            }
        }
    }

    private func executeQueuedActions() {
        let actions = pendingActions
        pendingActions.removeAll()
        actions.forEach { $0() }
    }
}
