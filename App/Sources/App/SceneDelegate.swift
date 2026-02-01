//
//  SceneDelegate.swift
//  Application
//
//  Created by Chao Wang on 07/01/2026.
//

import UIKit
import FunUI
import FunViewModel
import FunToolbox
import FunModel
import FunServices
import FunCoordinator

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // MARK: - Register Services (Dependency Injection)
        // Concrete implementations from CoreServices
        // IMPORTANT: Must be synchronous - app needs services before starting

        // Register logger service
        ServiceLocator.shared.register(
            DefaultLoggerService(),
            for: .logger
        )

        // Register network service
        ServiceLocator.shared.register(
            DefaultNetworkService(),
            for: .network
        )

        // Register favorites service
        ServiceLocator.shared.register(
            DefaultFavoritesService(),
            for: .favorites
        )

        // Register toast service
        ServiceLocator.shared.register(
            DefaultToastService(),
            for: .toast
        )

        // Register feature toggle service
        ServiceLocator.shared.register(
            DefaultFeatureToggleService(),
            for: .featureToggles
        )

        // Add more services here as needed
        print("✅ Services registered successfully")

        // MARK: - Setup Window

        let window = UIWindow(windowScene: windowScene)

        // Create root navigation controller
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)

        // Create and start app coordinator
        let coordinator = AppCoordinator(navigationController: navigationController)
        coordinator.start()

        // Store coordinator to prevent deallocation
        self.appCoordinator = coordinator

        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
