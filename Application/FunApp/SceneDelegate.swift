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

    // Service for appearance management (resolved after registration)
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

        // Create and start app coordinator with session factory
        let coordinator = AppCoordinator(
            navigationController: navigationController,
            sessionFactory: AppSessionFactory()
        )
        coordinator.start()

        // Store coordinator to prevent deallocation
        self.appCoordinator = coordinator

        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()

        // Apply initial appearance and observe changes
        updateAppearance()
        observeAppearanceChanges()
    }

    // MARK: - Appearance (Single Source of Truth)

    private func observeAppearanceChanges() {
        featureToggleService.featureTogglesDidChange
            .map { [weak self] in self?.featureToggleService.darkModeEnabled }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAppearance()
            }
            .store(in: &cancellables)
    }

    private func updateAppearance() {
        let isDarkMode = featureToggleService.darkModeEnabled
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        window?.overrideUserInterfaceStyle = style
    }

    // MARK: - Deep Link Handling

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let deepLink = DeepLink(url: url) else { return }
        appCoordinator?.handleDeepLink(deepLink)
    }
}
