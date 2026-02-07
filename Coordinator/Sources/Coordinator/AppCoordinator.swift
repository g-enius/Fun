//
//  AppCoordinator.swift
//  Coordinator
//
//  Main coordinator for the application
//

import UIKit

import FunCore
import FunModel
import FunUI
import FunViewModel

/// Main app coordinator that manages the root navigation and app flow
public final class AppCoordinator: BaseCoordinator {

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService

    // MARK: - Session Management

    private let sessionFactory: SessionFactory
    private var currentSession: Session?

    // MARK: - App Flow State

    private var currentFlow: AppFlow = .login

    // MARK: - Child Coordinators

    private var loginCoordinator: LoginCoordinatorImpl?
    private var homeCoordinator: HomeCoordinatorImpl?
    private var itemsCoordinator: ItemsCoordinatorImpl?
    private var settingsCoordinator: SettingsCoordinatorImpl?

    // Store tab bar view model for tab switching
    private var tabBarViewModel: HomeTabBarViewModel?

    // Queue deep link if received during login flow
    private var pendingDeepLink: DeepLink?

    // MARK: - Init

    public init(navigationController: UINavigationController, sessionFactory: SessionFactory) {
        self.sessionFactory = sessionFactory
        super.init(navigationController: navigationController)
    }

    // MARK: - Start

    override public func start() {
        activateSession(for: currentFlow)
        switch currentFlow {
        case .login:
            showLoginFlow()
        case .main:
            showMainFlow()
        }
    }

    // MARK: - Session Lifecycle

    private func activateSession(for flow: AppFlow) {
        currentSession?.teardown()
        let session = sessionFactory.makeSession(for: flow)
        session.activate()
        currentSession = session
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
            navigationController: homeNavController
        )
        let itemsCoordinator = ItemsCoordinatorImpl(
            navigationController: itemsNavController
        )
        let settingsCoordinator = SettingsCoordinatorImpl(
            navigationController: settingsNavController
        )

        // Set up logout callback through home coordinator (Profile modal)
        homeCoordinator.onLogout = { [weak self] in
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

        // Set as root (tab bar doesn't push, it's the container)
        navigationController.setViewControllers([tabBarController], animated: false)
    }

    // MARK: - Flow Transitions

    private func transitionToMainFlow() {
        currentFlow = .main
        activateSession(for: .main)
        showMainFlow()

        // Execute pending deep link after main flow is ready
        if let deepLink = pendingDeepLink {
            pendingDeepLink = nil
            // Small delay to ensure UI is ready
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 100_000_000)
                self?.executeDeepLink(deepLink)
            }
        }
    }

    private func transitionToLoginFlow() {
        currentFlow = .login
        activateSession(for: .login)
        showLoginFlow()
    }

    // MARK: - Cleanup

    private func clearMainFlowCoordinators() {
        homeCoordinator = nil
        itemsCoordinator = nil
        settingsCoordinator = nil
        tabBarViewModel = nil
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
            tabBarViewModel?.switchToTab(tabIndex.rawValue)

        case .item(let id):
            tabBarViewModel?.switchToTab(TabIndex.home.rawValue)
            if let item = FeaturedItem.all.first(where: { $0.id == id }) {
                homeCoordinator?.showDetail(for: item)
            } else {
                logger.log("Deep link item not found: \(id)", level: .warning, category: .general)
            }

        case .profile:
            tabBarViewModel?.switchToTab(TabIndex.home.rawValue)
            homeCoordinator?.showProfile()
        }
    }
}
