//
//  AppCoordinator.swift
//  Coordinator
//
//  Main coordinator for the application
//

import UIKit
import FunUI
import FunViewModel
import FunModel
import FunCore

/// Main app coordinator that manages the root navigation and app flow
public final class AppCoordinator: BaseCoordinator {

    // MARK: - App Flow State

    private var currentFlow: AppFlow = .login

    // MARK: - Child Coordinators

    private var loginCoordinator: LoginCoordinatorImpl?
    private var homeCoordinator: HomeCoordinatorImpl?
    private var itemsCoordinator: ItemsCoordinatorImpl?
    private var settingsCoordinator: SettingsCoordinatorImpl?

    // Store tab bar view model for tab switching
    private var tabBarViewModel: HomeTabBarViewModel?

    // Store tab bar controller for deep link navigation
    private weak var tabBarController: UITabBarController?

    // Queue deep link if received during login flow
    private var pendingDeepLink: DeepLink?

    // MARK: - Start

    override public func start() {
        switch currentFlow {
        case .login:
            showLoginFlow()
        case .main:
            showMainFlow()
        }
    }

    // MARK: - Flow Management

    private func showLoginFlow() {
        // Clear any existing main flow coordinators
        clearMainFlowCoordinators()

        let loginCoordinator = LoginCoordinatorImpl(navigationController: navigationController)
        loginCoordinator.onLoginSuccess = { [weak self] in
            self?.transitionToMainFlow()
        }
        self.loginCoordinator = loginCoordinator
        loginCoordinator.start()
    }

    private func showMainFlow() {
        // Clear login coordinator
        loginCoordinator = nil

        // Create navigation controllers for each tab
        let homeNavController = UINavigationController()
        let itemsNavController = UINavigationController()
        let settingsNavController = UINavigationController()

        // Configure tab bar items with icons and titles
        homeNavController.tabBarItem = UITabBarItem(
            title: L10n.Tabs.home,
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        itemsNavController.tabBarItem = UITabBarItem(
            title: L10n.Tabs.items,
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )

        settingsNavController.tabBarItem = UITabBarItem(
            title: L10n.Tabs.settings,
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        // Create view model for tab bar
        let tabBarViewModel = HomeTabBarViewModel()
        self.tabBarViewModel = tabBarViewModel

        // Create and store coordinators for each tab
        let homeCoordinator = HomeCoordinatorImpl(
            navigationController: homeNavController,
            tabBarViewModel: tabBarViewModel
        )
        let itemsCoordinator = ItemsCoordinatorImpl(
            navigationController: itemsNavController,
            tabBarViewModel: tabBarViewModel
        )
        let settingsCoordinator = SettingsCoordinatorImpl(
            navigationController: settingsNavController
        )

        // Set up logout callback
        settingsCoordinator.onLogout = { [weak self] in
            self?.transitionToLoginFlow()
        }

        // Store coordinators to prevent deallocation
        self.homeCoordinator = homeCoordinator
        self.itemsCoordinator = itemsCoordinator
        self.settingsCoordinator = settingsCoordinator

        // Start each coordinator's flow
        homeCoordinator.start()
        itemsCoordinator.start()
        settingsCoordinator.start()

        // Create tab bar with view model and navigation controllers
        let tabBarController = HomeTabBarController(
            viewModel: tabBarViewModel,
            tabNavigationControllers: [
                homeNavController,
                itemsNavController,
                settingsNavController
            ]
        )

        // Store reference for deep link navigation
        self.tabBarController = tabBarController

        // Set as root (tab bar doesn't push, it's the container)
        navigationController.setViewControllers([tabBarController], animated: false)
    }

    // MARK: - Flow Transitions

    private func transitionToMainFlow() {
        currentFlow = .main
        showMainFlow()

        // Execute pending deep link after main flow is ready
        if let deepLink = pendingDeepLink {
            pendingDeepLink = nil
            // Small delay to ensure UI is ready
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000)
                executeDeepLink(deepLink)
            }
        }
    }

    private func transitionToLoginFlow() {
        currentFlow = .login
        showLoginFlow()
    }

    // MARK: - Cleanup

    private func clearMainFlowCoordinators() {
        homeCoordinator = nil
        itemsCoordinator = nil
        settingsCoordinator = nil
        tabBarViewModel = nil
        tabBarController = nil
    }

    // MARK: - Deep Link Handling

    /// Handle incoming deep link
    /// - Parameter deepLink: The deep link to handle
    public func handleDeepLink(_ deepLink: DeepLink) {
        // If on login screen, queue for after login
        if currentFlow == .login {
            pendingDeepLink = deepLink
            return
        }

        executeDeepLink(deepLink)
    }

    private func executeDeepLink(_ deepLink: DeepLink) {
        switch deepLink {
        case .tab(let tabIndex):
            tabBarController?.selectedIndex = tabIndex.rawValue

        case .item(let id):
            tabBarController?.selectedIndex = TabIndex.home.rawValue
            if let item = FeaturedItem.all.first(where: { $0.id == id }) {
                homeCoordinator?.showDetail(for: item)
            }

        case .profile:
            tabBarController?.selectedIndex = TabIndex.home.rawValue
            homeCoordinator?.showProfile()
        }
    }
}
