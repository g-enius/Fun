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
public final class AppCoordinator: ServiceLocatorProvider {

    // MARK: - DI

    @ObservationIgnored public let serviceLocator: ServiceLocator
    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol
    @ObservationIgnored @Service(.toast) private var toastService: ToastServiceProtocol

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
    @ObservationIgnored private var darkModeObservation: Task<Void, Never>?

    // MARK: - Init

    public init(sessionFactory: SessionFactory, serviceLocator: ServiceLocator) {
        self.sessionFactory = sessionFactory
        self.serviceLocator = serviceLocator
    }

    deinit {
        toastObservation?.cancel()
        darkModeObservation?.cancel()
    }

    // MARK: - Start

    public func start() {
        activateSession(for: currentFlow)
        observeToastEvents()
        subscribeToDarkMode()
    }

    // MARK: - Session Lifecycle

    private func activateSession(for flow: AppFlow) {
        currentSession?.teardown()
        let session = sessionFactory.makeSession(for: flow, serviceLocator: serviceLocator)
        session.activate()
        currentSession = session
    }

    // MARK: - Navigation

    public func showDetail(_ item: FeaturedItem, in tab: TabIndex) {
        switch tab {
        case .home: homePath.append(item)
        case .items: itemsPath.append(item)
        default: break
        }
    }

    public func showProfile() {
        isProfilePresented = true
    }

    public func dismissProfile() {
        isProfilePresented = false
    }

    public func selectTab(_ tab: TabIndex) {
        selectedTab = tab
    }

    public func popToRoot() {
        homePath = NavigationPath()
        itemsPath = NavigationPath()
        settingsPath = NavigationPath()
    }

    // MARK: - Routing

    @ViewBuilder
    func destinationView(for item: FeaturedItem) -> some View {
        DetailTabContent(item: item, coordinator: self)
    }


    // MARK: - Flow Transitions

    public func transitionToMainFlow() {
        currentFlow = .main
        activateSession(for: .main)
        observeToastEvents()
        subscribeToDarkMode()

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
        subscribeToDarkMode()
        toastObservation?.cancel()

        // Reset navigation state
        popToRoot()
        selectTab(.home)
        dismissProfile()
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
            selectTab(tabIndex)

        case .item(let id):
            selectTab(.home)
            if let item = FeaturedItem.all.first(where: { $0.id == id }) {
                showDetail(item, in: .home)
            } else {
                logger.log("Deep link item not found: \(id)", level: .warning, category: .general)
            }

        case .profile:
            selectTab(.home)
            showProfile()
        }
    }

    // MARK: - Toast

    private func observeToastEvents() {
        toastObservation?.cancel()
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

    private func subscribeToDarkMode() {
        darkModeObservation?.cancel()
        appearanceMode = featureToggleService.appearanceMode
        let stream = featureToggleService.appearanceModeChanges
        darkModeObservation = Task { [weak self] in
            for await mode in stream {
                guard let self else { break }
                self.appearanceMode = mode
            }
        }
    }
}
