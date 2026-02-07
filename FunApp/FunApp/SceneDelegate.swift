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
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private var darkModeCancellable: AnyCancellable?

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

        // Observe before coordinator.start() so serviceDidRegister triggers initial subscription
        observeDarkMode()

        // Create and start app coordinator with session factory
        let coordinator = AppCoordinator(
            navigationController: navigationController,
            sessionFactory: AppSessionFactory()
        )
        coordinator.start()
        self.appCoordinator = coordinator

        window.makeKeyAndVisible()
    }

    // MARK: - Dark Mode Observation

    private func observeDarkMode() {
        ServiceLocator.shared.serviceDidRegister
            .filter { $0 == .featureToggles }
            .sink { [weak self] _ in
                self?.subscribeToDarkMode()
            }
            .store(in: &cancellables)
    }

    private func subscribeToDarkMode() {
        // Cancel previous subscription to avoid duplicates on repeated registrations
        darkModeCancellable?.cancel()
        guard ServiceLocator.shared.isRegistered(for: .featureToggles) else { return }
        let toggleService: FeatureToggleServiceProtocol = ServiceLocator.shared.resolve(for: .featureToggles)
        darkModeCancellable = toggleService.darkModePublisher
            .sink { [weak self] isDarkMode in
                let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
                self?.window?.overrideUserInterfaceStyle = style
            }
    }

    // MARK: - Scene Lifecycle

    func sceneDidDisconnect(_ scene: UIScene) {
        appCoordinator = nil
        cancellables.removeAll()
        darkModeCancellable = nil
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Resume any paused work
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause ongoing tasks when going inactive
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save any transient state
    }

    // MARK: - Deep Link Handling

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let deepLink = DeepLink(url: url) else { return }
        appCoordinator?.handleDeepLink(deepLink)
    }
}
