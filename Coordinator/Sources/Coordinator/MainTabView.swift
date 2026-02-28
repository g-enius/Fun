//
//  MainTabView.swift
//  Coordinator
//
//  Main tab view with NavigationStack per tab, profile sheet, and toast overlay.
//  Lives in Coordinator (not FunUI) because it depends on AppCoordinator.
//  Moving to FunUI would create a circular dependency: Coordinator → UI → Coordinator.
//

import SwiftUI

import FunCore
import FunModel
import FunUI
import FunViewModel

struct MainTabView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            homeTab
            itemsTab
            settingsTab
        }
        .sheet(isPresented: $coordinator.isProfilePresented) {
            NavigationStack {
                ProfileTabContent(coordinator: coordinator)
            }
        }
        .overlay(alignment: .top) {
            if let toast = coordinator.activeToast {
                ToastView(
                    message: toast.message,
                    type: toast.type,
                    onDismiss: { coordinator.dismissToast() }
                )
            }
        }
    }

    // MARK: - Tabs

    private var homeTab: some View {
        NavigationStack(path: $coordinator.homePath) {
            HomeTabContent(coordinator: coordinator)
                .navigationDestination(for: FeaturedItem.self) { item in
                    coordinator.destinationView(for: item)
                }
        }
        .tabItem {
            Label(L10n.Tabs.home, systemImage: "house")
        }
        .tag(TabIndex.home)
        .accessibilityIdentifier(AccessibilityID.Tabs.home)
    }

    private var itemsTab: some View {
        NavigationStack(path: $coordinator.itemsPath) {
            ItemsTabContent(coordinator: coordinator)
                .navigationDestination(for: FeaturedItem.self) { item in
                    coordinator.destinationView(for: item)
                }
        }
        .tabItem {
            Label(L10n.Tabs.items, systemImage: "list.bullet")
        }
        .tag(TabIndex.items)
        .accessibilityIdentifier(AccessibilityID.Tabs.items)
    }

    private var settingsTab: some View {
        NavigationStack(path: $coordinator.settingsPath) {
            SettingsTabContent(coordinator: coordinator)
        }
        .tabItem {
            Label(L10n.Tabs.settings, systemImage: "gearshape")
        }
        .tag(TabIndex.settings)
        .accessibilityIdentifier(AccessibilityID.Tabs.settings)
    }
}

// MARK: - Tab Content Views

/// Wrapper that creates HomeViewModel with navigation closures wired to coordinator
struct HomeTabContent: View {
    let coordinator: AppCoordinator
    @StateObject private var viewModel: HomeViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: HomeViewModel(serviceLocator: coordinator.serviceLocator))
    }

    var body: some View {
        HomeView(viewModel: viewModel)
            .task {
                viewModel.onShowDetail = { [weak coordinator] item in
                    coordinator?.showDetail(item, in: .home)
                }
                viewModel.onShowProfile = { [weak coordinator] in
                    coordinator?.showProfile()
                }
            }
    }
}

/// Wrapper that creates ItemsViewModel with navigation closures wired to coordinator
struct ItemsTabContent: View {
    let coordinator: AppCoordinator
    @StateObject private var viewModel: ItemsViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: ItemsViewModel(serviceLocator: coordinator.serviceLocator))
    }

    var body: some View {
        ItemsView(viewModel: viewModel)
            .task {
                viewModel.onShowDetail = { [weak coordinator] item in
                    coordinator?.showDetail(item, in: .items)
                }
            }
    }
}

/// Wrapper that creates SettingsViewModel
struct SettingsTabContent: View {
    let coordinator: AppCoordinator
    @StateObject private var viewModel: SettingsViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: SettingsViewModel(serviceLocator: coordinator.serviceLocator))
    }

    var body: some View {
        SettingsView(viewModel: viewModel)
    }
}

/// Wrapper that creates DetailViewModel for a pushed item
struct DetailTabContent: View {
    let coordinator: AppCoordinator
    @StateObject private var viewModel: DetailViewModel

    init(item: FeaturedItem, coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: DetailViewModel(item: item, serviceLocator: coordinator.serviceLocator))
    }

    var body: some View {
        DetailView(viewModel: viewModel)
    }
}

/// Wrapper that creates ProfileViewModel with navigation closures
struct ProfileTabContent: View {
    let coordinator: AppCoordinator
    @StateObject private var viewModel: ProfileViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: ProfileViewModel(serviceLocator: coordinator.serviceLocator))
    }

    var body: some View {
        ProfileView(viewModel: viewModel)
            .task {
                viewModel.onDismiss = { [weak coordinator] in
                    coordinator?.dismissProfile()
                }
                viewModel.onLogout = { [weak coordinator] in
                    coordinator?.dismissProfile()
                    coordinator?.transitionToLoginFlow()
                }
                viewModel.onGoToItems = { [weak coordinator] in
                    coordinator?.dismissProfile()
                    coordinator?.selectTab(.items)
                }
            }
    }
}

/// Wrapper that creates LoginViewModel with login success closure
struct LoginTabContent: View {
    let coordinator: AppCoordinator
    @StateObject private var viewModel: LoginViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: LoginViewModel(serviceLocator: coordinator.serviceLocator))
    }

    var body: some View {
        LoginView(viewModel: viewModel)
            .task {
                viewModel.onLoginSuccess = { [weak coordinator] in
                    coordinator?.transitionToMainFlow()
                }
            }
    }
}
