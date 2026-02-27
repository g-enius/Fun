//
//  AppCoordinator.swift
//  Coordinator
//
//  SwiftUI-based coordinator managing navigation state and app flow
//

import Combine
import SwiftUI

import FunCore
import FunModel

@MainActor
public final class AppCoordinator: ObservableObject, SessionProvider {

    // MARK: - DI

    public private(set) var session: Session
    @Service(.logger) private var logger: LoggerService
    @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol
    @Service(.toast) private var toastService: ToastServiceProtocol

    // MARK: - Session Management

    private let sessionFactory: SessionFactory

    // MARK: - App Flow State

    @Published public var currentFlow: AppFlow = .login

    // MARK: - Navigation State

    @Published public var selectedTab: TabIndex = .home
    @Published public var homePath = NavigationPath()
    @Published public var itemsPath = NavigationPath()
    @Published public var settingsPath = NavigationPath()
    @Published public var isProfilePresented = false

    // MARK: - Deep Link

    private var pendingDeepLink: DeepLink?

    // MARK: - Toast

    @Published public var activeToast: ToastEvent?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Dark Mode

    @Published public var appearanceMode: AppearanceMode = .system
    private var darkModeCancellable: AnyCancellable?

    // MARK: - Init

    public init(sessionFactory: SessionFactory) {
        self.sessionFactory = sessionFactory
        self.session = sessionFactory.makeSession(for: .login)
    }

    // MARK: - Start

    public func start() {
        activateCurrentSession()
        observeToastEvents()
        subscribeToDarkMode()
    }

    // MARK: - Session Lifecycle

    private func activateCurrentSession() {
        session.activate()
    }

    private func activateSession(for flow: AppFlow) {
        session.teardown()
        session = sessionFactory.makeSession(for: flow)
        activateCurrentSession()
    }

    // MARK: - Flow Transitions

    public func transitionToMainFlow() {
        currentFlow = .main
        activateSession(for: .main)
        observeToastEvents()
        subscribeToDarkMode()

        if let deepLink = pendingDeepLink {
            pendingDeepLink = nil
            executeDeepLink(deepLink)
        }
    }

    public func transitionToLoginFlow() {
        currentFlow = .login
        pendingDeepLink = nil
        activateSession(for: .login)

        // Reset navigation state
        homePath = NavigationPath()
        itemsPath = NavigationPath()
        settingsPath = NavigationPath()
        selectedTab = .home
        isProfilePresented = false
        activeToast = nil
    }

    // MARK: - Deep Link Handling

    public func handleDeepLink(_ deepLink: DeepLink) {
        if currentFlow == .login {
            pendingDeepLink = deepLink
            return
        }
        executeDeepLink(deepLink)
    }

    private func executeDeepLink(_ deepLink: DeepLink) {
        switch deepLink {
        case .tab(let tabIndex):
            selectedTab = tabIndex

        case .item(let id):
            selectedTab = .home
            if let item = FeaturedItem.all.first(where: { $0.id == id }) {
                homePath.append(item)
            } else {
                logger.log("Deep link item not found: \(id)", level: .warning, category: .general)
            }

        case .profile:
            selectedTab = .home
            isProfilePresented = true
        }
    }

    // MARK: - Toast

    private func observeToastEvents() {
        toastService.toastPublisher
            .sink { [weak self] event in
                self?.activeToast = event
            }
            .store(in: &cancellables)
    }

    public func dismissToast() {
        activeToast = nil
    }

    // MARK: - Dark Mode Observation

    private func subscribeToDarkMode() {
        darkModeCancellable?.cancel()
        darkModeCancellable = featureToggleService.appearanceModePublisher
            .sink { [weak self] mode in
                self?.appearanceMode = mode
            }
    }
}
