//
//  HomeTabBarController.swift
//  UI
//
//  Tab bar controller that displays the main tabs of the app
//  Coordinators are injected from outside to avoid circular dependencies
//

import UIKit
import SwiftUI
import Combine
import FunCore
import FunViewModel
import FunModel

public class HomeTabBarController: UITabBarController {

    // MARK: - ViewModel

    private let viewModel: HomeTabBarViewModel

    // MARK: - Services

    @Service(.toast) private var toastService: ToastServiceProtocol
    @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Toast UI

    private var toastHostingController: UIHostingController<ToastView>?

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

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Sync initial tab selection
        viewModel.selectedTabIndex = selectedIndex

        // Observe view model for programmatic tab changes
        Task { @MainActor [weak self] in
            guard let self else { return }
            for await index in viewModel.$selectedTabIndex.values where self.selectedIndex != index {
                self.selectedIndex = index
            }
        }

        updateAppearance()
        observeAppSettingChanges()
        observeToastEvents()
    }

    // MARK: - Toast Observation

    private func observeToastEvents() {
        toastService.toastPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.showToast(message: event.message, type: event.type)
            }
            .store(in: &cancellables)
    }

    private func showToast(message: String, type: ToastType) {
        // Remove existing toast if any
        toastHostingController?.view.removeFromSuperview()
        toastHostingController = nil

        let toastView = ToastView(message: message, type: type) { [weak self] in
            self?.dismissToast()
        }

        let hostingController = UIHostingController(rootView: toastView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 100)
        ])

        toastHostingController = hostingController
    }

    private func dismissToast() {
        toastHostingController?.view.removeFromSuperview()
        toastHostingController = nil
    }

    // MARK: - Appearance (Combine)

    private func observeAppSettingChanges() {
        AppSettingsPublisher.shared.settingsDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateAppearance()
            }
            .store(in: &cancellables)
    }

    private func updateAppearance() {
        let isDarkModeEnabled = featureToggleService.darkModeEnabled
        let style: UIUserInterfaceStyle = isDarkModeEnabled ? .dark : .light
        overrideUserInterfaceStyle = style

        if let windowScene = view.window?.windowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        }

        if let presented = presentedViewController {
            presented.overrideUserInterfaceStyle = style
        }
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
