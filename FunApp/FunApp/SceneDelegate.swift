//
//  SceneDelegate.swift
//  FunApp
//
//  Created by Charles Wang on 30/01/2026.
//

import Combine
import UIKit

import FunCoordinator
import FunCore
import FunModel

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate, ServiceLocatorProvider {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    let serviceLocator = ServiceLocator()
    private var darkModeCancellable: AnyCancellable?

    @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // MARK: - Setup Window

        let window = UIWindow(windowScene: windowScene)

        // Create root navigation controller
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)

        window.rootViewController = navigationController
        self.window = window

        // Create and start app coordinator with session factory
        let coordinator = AppCoordinator(
            navigationController: navigationController,
            sessionFactory: AppSessionFactory(),
            serviceLocator: serviceLocator
        )
        coordinator.start()
        self.appCoordinator = coordinator

        // Subscribe to dark mode after coordinator.start() has activated the session
        subscribeToDarkMode()

        window.makeKeyAndVisible()

        // Handle deep link from cold start
        if let url = connectionOptions.urlContexts.first?.url,
           let deepLink = DeepLink(url: url) {
            coordinator.handleDeepLink(deepLink)
        }
    }

    // MARK: - Dark Mode Observation

    private func subscribeToDarkMode() {
        darkModeCancellable?.cancel()
        darkModeCancellable = featureToggleService.appearanceModePublisher
            .sink { [weak self] mode in
                let style: UIUserInterfaceStyle = switch mode {
                case .system: .unspecified
                case .light: .light
                case .dark: .dark
                }
                self?.window?.overrideUserInterfaceStyle = style
            }
    }

    // MARK: - Deep Link Handling

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let deepLink = DeepLink(url: url) else { return }
        appCoordinator?.handleDeepLink(deepLink)
    }
}
