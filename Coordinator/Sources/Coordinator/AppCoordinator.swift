//
//  AppCoordinator.swift
//  Coordinator
//
//  SwiftUI-based coordinator managing navigation state and app flow
//

import Observation
import SwiftUI

import FunCore
import FunModel

@MainActor
@Observable
public final class AppCoordinator {

    // MARK: - Services

    @ObservationIgnored @Service(.logger) private var logger: LoggerService

    // MARK: - Session Management

    @ObservationIgnored private let sessionFactory: SessionFactory
    @ObservationIgnored private var currentSession: Session?

    // MARK: - App Flow State

    public var currentFlow: AppFlow = .login

    // MARK: - Navigation State

    public var selectedTab: TabIndex = .home
    public var homePath = NavigationPath()
    public var itemsPath = NavigationPath()
    public var settingsPath = NavigationPath()
    public var isProfilePresented = false

    // MARK: - Deep Link

    @ObservationIgnored private var pendingDeepLink: DeepLink?

    // MARK: - Toast

    public var activeToast: ToastEvent?
    @ObservationIgnored private var toastObservation: Task<Void, Never>?

    // MARK: - Dark Mode

    public var appearanceMode: AppearanceMode = .system
    @ObservationIgnored private var registrationObservation: Task<Void, Never>?
    @ObservationIgnored private var darkModeObservation: Task<Void, Never>?

    // MARK: - Init

    public init(sessionFactory: SessionFactory) {
        self.sessionFactory = sessionFactory
    }

    deinit {
        toastObservation?.cancel()
        registrationObservation?.cancel()
        darkModeObservation?.cancel()
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
        toastObservation?.cancel()
        @Service(.toast) var toastService: ToastServiceProtocol
        let stream = toastService.toastEvents
        toastObservation = Task { [weak self] in
            for await event in stream {
                guard let self else { break }
                self.activeToast = event
            }
        }
    }

    public func dismissToast() {
        activeToast = nil
    }

    // MARK: - Dark Mode Observation

    private func observeDarkMode() {
        let stream = ServiceLocator.shared.serviceRegistrations
        registrationObservation = Task { [weak self] in
            for await key in stream {
                guard let self else { break }
                if key == .featureToggles {
                    self.subscribeToDarkMode()
                }
            }
        }
    }

    private func subscribeToDarkMode() {
        darkModeObservation?.cancel()
        @Service(.featureToggles) var featureToggleService: FeatureToggleServiceProtocol
        let stream = featureToggleService.appearanceModeChanges
        darkModeObservation = Task { [weak self] in
            for await mode in stream {
                guard let self else { break }
                self.appearanceMode = mode
            }
        }
    }
}
