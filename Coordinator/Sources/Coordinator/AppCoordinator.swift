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
public final class AppCoordinator: ObservableObject {

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService
    @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol
    @Service(.toast) private var toastService: ToastServiceProtocol

    // MARK: - Session Management

    private let sessionFactory: SessionFactory
    private var currentSession: Session?

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
    }

    // MARK: - Start

    public func start() {
        activateSession(for: currentFlow)
        observeDarkMode()
    }

    // MARK: - Session Lifecycle

    private func activateSession(for flow: AppFlow) {
        currentSession?.teardown()
        let session = sessionFactory.makeSession(for: flow)
        session.activate()
        currentSession = session
    }

    // MARK: - Flow Transitions

    public func transitionToMainFlow() {
        currentFlow = .main
        activateSession(for: .main)
        observeToastEvents()

        // Execute pending deep link after main flow is ready
        if let deepLink = pendingDeepLink {
            pendingDeepLink = nil
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 100_000_000)
                self?.executeDeepLink(deepLink)
            }
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

    private func observeDarkMode() {
        ServiceLocator.shared.serviceDidRegisterPublisher
            .filter { $0 == .featureToggles }
            .sink { [weak self] _ in
                self?.subscribeToDarkMode()
            }
            .store(in: &cancellables)
    }

    private func subscribeToDarkMode() {
        darkModeCancellable?.cancel()
        darkModeCancellable = featureToggleService.appearanceModePublisher
            .sink { [weak self] mode in
                self?.appearanceMode = mode
            }
    }
}
