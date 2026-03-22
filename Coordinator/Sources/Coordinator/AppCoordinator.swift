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
public final class AppCoordinator: BaseCoordinator, SessionProvider {

    // MARK: - Services

    public private(set) var session: Session
    @Service(.logger) private var logger: LoggerService

    // MARK: - Session Management

    private let sessionFactory: SessionFactory

    // MARK: - App Flow State

    private var currentFlow: AppFlow = .login

    // MARK: - Child Coordinators

    private var loginCoordinator: LoginCoordinator?
    private var homeCoordinator: HomeCoordinator?
    private var itemsCoordinator: ItemsCoordinator?
    private var settingsCoordinator: SettingsCoordinator?

    // Store tab bar view model for tab switching
    private var tabBarViewModel: HomeTabBarViewModel?

    // Queue deep link if received during login flow
    private var pendingDeepLink: DeepLink?

    /// Called after each session activation so external observers can re-subscribe to session-scoped services
    public var onSessionActivated: (() -> Void)?

    // MARK: - Init

    public init(navigationController: UINavigationController, sessionFactory: SessionFactory) {
        self.sessionFactory = sessionFactory
        self.session = sessionFactory.makeSession(for: .login)
        super.init(navigationController: navigationController)
    }

    // MARK: - Start

    override public func start() {
        activateCurrentSession()
        switch currentFlow {
        case .login:
            showLoginFlow(session: session)
        case .main:
            showMainFlow(session: session)
        }
    }

    // MARK: - Session Lifecycle

    private func activateCurrentSession() {
        session.activate()
        onSessionActivated?()
    }

    private func activateSession(for flow: AppFlow) -> Session {
        session.teardown()
        session = sessionFactory.makeSession(for: flow)
        activateCurrentSession()
        return session
    }

    // MARK: - Flow Management

    private func showLoginFlow(session: Session) {
        // Clear any existing main flow coordinators
        clearMainFlowCoordinators()

        let loginCoordinator = LoginCoordinator(
            navigationController: navigationController,
            session: session
        )
        loginCoordinator.onLoginSuccess = { [weak self] in
            self?.transitionToMainFlow()
        }
        self.loginCoordinator = loginCoordinator
        loginCoordinator.start()
    }

    private func showMainFlow(session: Session) {
        // Clear login coordinator
        loginCoordinator = nil

        // Create navigation controllers for each tab
        let homeNavController = UINavigationController()
        let itemsNavController = UINavigationController()
        let settingsNavController = UINavigationController()

        // Large navigation titles for root screens
        homeNavController.navigationBar.prefersLargeTitles = true
        itemsNavController.navigationBar.prefersLargeTitles = true
        settingsNavController.navigationBar.prefersLargeTitles = true

        // Configure tab bar items with icons and titles
        homeNavController.tabBarItem = UITabBarItem(
            title: L10n.Tabs.home,
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        homeNavController.tabBarItem.accessibilityIdentifier = AccessibilityID.Tabs.home

        itemsNavController.tabBarItem = UITabBarItem(
            title: L10n.Tabs.items,
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )
        itemsNavController.tabBarItem.accessibilityIdentifier = AccessibilityID.Tabs.items

        settingsNavController.tabBarItem = UITabBarItem(
            title: L10n.Tabs.settings,
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        settingsNavController.tabBarItem.accessibilityIdentifier = AccessibilityID.Tabs.settings

        // Create view model for tab bar
        let tabBarViewModel = HomeTabBarViewModel(session: session)
        self.tabBarViewModel = tabBarViewModel

        // Create and store coordinators for each tab
        let homeCoordinator = HomeCoordinator(
            navigationController: homeNavController,
            session: session
        )
        let itemsCoordinator = ItemsCoordinator(
            navigationController: itemsNavController,
            session: session
        )
        let settingsCoordinator = SettingsCoordinator(
            navigationController: settingsNavController,
            session: session
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
            ],
            session: session
        )

        // Set as root (tab bar doesn't push, it's the container)
        navigationController.setViewControllers([tabBarController], animated: false)
    }

    // MARK: - Flow Transitions

    private func transitionToMainFlow() {
        currentFlow = .main
        let session = activateSession(for: .main)
        showMainFlow(session: session)

        if let deepLink = pendingDeepLink {
            pendingDeepLink = nil
            executeDeepLink(deepLink)
        }
    }

    private func transitionToLoginFlow() {
        currentFlow = .login
        pendingDeepLink = nil
        let session = activateSession(for: .login)
        showLoginFlow(session: session)
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
