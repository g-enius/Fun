//
//  AppCoordinator.swift
//  Coordinator
//
//  Main coordinator for the application
//

import UIKit
import FunUI
import FunViewModel

/// Main app coordinator that manages the root navigation
public final class AppCoordinator: BaseCoordinator {

    // MARK: - Child Coordinators

    // Store child coordinators to prevent deallocation
    // ViewModels hold weak references, so coordinators must be retained
    private var tab1Coordinator: Tab1CoordinatorImpl?
    private var tab2Coordinator: Tab2CoordinatorImpl?
    private var tab3Coordinator: Tab3CoordinatorImpl?
    private var tab4Coordinator: Tab5CoordinatorImpl? // Tab 4 is Settings (was Tab 5)

    // Store tab bar view model for tab switching
    private var tabBarViewModel: HomeTabBarViewModel?

    public override func start() {
        // Create navigation controllers for each tab
        let tab1NavController = UINavigationController()
        let tab2NavController = UINavigationController()
        let tab3NavController = UINavigationController()
        let tab4NavController = UINavigationController()

        // Configure tab bar items with icons and titles
        tab1NavController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        tab2NavController.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        tab3NavController.tabBarItem = UITabBarItem(
            title: "Items",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )

        tab4NavController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        // Create view model for tab bar
        let tabBarViewModel = HomeTabBarViewModel()
        self.tabBarViewModel = tabBarViewModel

        // Create and store coordinators for each tab
        let tab1Coordinator = Tab1CoordinatorImpl(
            navigationController: tab1NavController,
            tabBarViewModel: tabBarViewModel
        )
        let tab2Coordinator = Tab2CoordinatorImpl(
            navigationController: tab2NavController,
            tabBarViewModel: tabBarViewModel
        )
        let tab3Coordinator = Tab3CoordinatorImpl(
            navigationController: tab3NavController,
            tabBarViewModel: tabBarViewModel
        )
        let tab4Coordinator = Tab5CoordinatorImpl(
            navigationController: tab4NavController
        )

        // Store coordinators to prevent deallocation
        self.tab1Coordinator = tab1Coordinator
        self.tab2Coordinator = tab2Coordinator
        self.tab3Coordinator = tab3Coordinator
        self.tab4Coordinator = tab4Coordinator

        // Start each coordinator's flow
        tab1Coordinator.start()
        tab2Coordinator.start()
        tab3Coordinator.start()
        tab4Coordinator.start()

        // Create tab bar with view model and navigation controllers
        let tabBarController = HomeTabBarController(
            viewModel: tabBarViewModel,
            tabNavigationControllers: [
                tab1NavController,
                tab2NavController,
                tab3NavController,
                tab4NavController
            ]
        )

        // Set as root (tab bar doesn't push, it's the container)
        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
