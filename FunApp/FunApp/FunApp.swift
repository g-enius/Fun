//
//  FunApp.swift
//  FunApp
//
//  SwiftUI App entry point
//

import SwiftUI

import FunCoordinator
import FunModel

@main
struct FunApp: App {
    @State private var coordinator = AppCoordinator(
        sessionFactory: AppSessionFactory()
    )

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: coordinator)
                .onOpenURL { url in
                    if let deepLink = DeepLink(url: url) {
                        coordinator.handleDeepLink(deepLink)
                    }
                }
                .task {
                    coordinator.start()
                }
        }
    }
}
