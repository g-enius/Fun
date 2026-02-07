//
//  SceneDelegate.swift
//  FunApp
//
//  Created by Charles Wang on 30/01/2026.
//

import UIKit
import Combine
import FunUI
import FunViewModel
import FunCore
import FunModel
import FunCoordinator

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private var darkModeSubscription: AnyCancellable?

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
        darkModeSubscription?.cancel()
        darkModeSubscription = featureToggleService.featureTogglesDidChange
            .filter { $0 == .darkMode }
            .compactMap { [weak self] _ in self?.featureToggleService.darkModeEnabled }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDarkMode in
                let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
                self?.window?.overrideUserInterfaceStyle = style
            }

        // Apply current value immediately
        let isDarkMode = featureToggleService.darkModeEnabled
        window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }

    // MARK: - Deep Link Handling

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let deepLink = DeepLink(url: url) else { return }
        appCoordinator?.handleDeepLink(deepLink)
    }
}
