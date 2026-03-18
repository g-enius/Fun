//
//  AppRootView.swift
//  Coordinator
//
//  Root SwiftUI view that switches between login and main tab flow.
//  Lives in Coordinator (not FunUI) because it depends on AppCoordinator.
//  Moving to FunUI would create a circular dependency: Coordinator → UI → Coordinator.
//

import SwiftUI

import FunCore
import FunModel
import FunUI
import FunViewModel

public struct AppRootView: View {
    @ObservedObject var coordinator: AppCoordinator

    public init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        Group {
            switch coordinator.currentFlow {
            case .login:
                LoginContent(coordinator: coordinator)
            case .main:
                MainTabView(coordinator: coordinator)
            }
        }
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch coordinator.appearanceMode {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
