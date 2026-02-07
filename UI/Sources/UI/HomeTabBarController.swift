//
//  HomeTabBarController.swift
//  UI
//
//  Tab bar controller that displays the main tabs of the app
//  Coordinators are injected from outside to avoid circular dependencies
//

import Combine
import SwiftUI
import UIKit

import FunCore
import FunModel
import FunViewModel

public class HomeTabBarController: UITabBarController {

    // MARK: - ViewModel

    private let viewModel: HomeTabBarViewModel

    // MARK: - Services

    @Service(.toast) private var toastService: ToastServiceProtocol

    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Toast UI

    private var toastHostingController: UIHostingController<ToastView>?

    // MARK: - Tasks

    private var tabObservationTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(viewModel: HomeTabBarViewModel, tabNavigationControllers: [UINavigationController]) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        delegate = self
        viewControllers = tabNavigationControllers
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        tabObservationTask?.cancel()
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Sync initial tab selection
        viewModel.selectedTabIndex = selectedIndex

        // Observe view model for programmatic tab changes
        tabObservationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await index in viewModel.$selectedTabIndex.values where self.selectedIndex != index {
                self.selectedIndex = index
            }
        }

        observeToastEvents()
    }

    // MARK: - Toast Observation

    private func observeToastEvents() {
        toastService.toastPublisher
            .sink { [weak self] event in
                self?.showToast(message: event.message, type: event.type)
            }
            .store(in: &cancellables)
    }

    private func showToast(message: String, type: ToastType) {
        // Remove existing toast if any
        dismissToast()

        let toastView = ToastView(message: message, type: type) { [weak self] in
            self?.dismissToast()
        }

        let hostingController = UIHostingController(rootView: toastView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        // Proper child view controller management
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 100)
        ])

        toastHostingController = hostingController
    }

    private func dismissToast() {
        guard let hostingController = toastHostingController else { return }
        hostingController.willMove(toParent: nil)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
        toastHostingController = nil
    }

}

// MARK: - UITabBarControllerDelegate

extension HomeTabBarController: UITabBarControllerDelegate {
    public func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        viewModel.tabDidChange(to: selectedIndex)
    }
}
