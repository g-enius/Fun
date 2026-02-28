//
//  TechnologyDescriptions.swift
//  Model
//
//  Detailed descriptions for each technology showcased in the demo app
//

import Foundation

public enum TechnologyItem: String, CaseIterable, Sendable {
    case asyncAwait = "asyncawait"
    case combine = "combine"
    case swiftUI = "swiftui"
    case coordinator = "coordinator"
    case mvvm = "mvvm"
    case spm = "spm"
    case serviceLocator = "servicelocator"
    case protocolOriented = "protocol"
    case featureToggles = "featuretoggles"
    case osLog = "oslog"
    case swift6 = "swift6"
    case swiftTesting = "swifttesting"
    case snapshotTesting = "snapshot"
    case accessibility = "accessibility"
    case deploymentTarget = "deploymenttarget"
    case concurrencyPatterns = "concurrencypatterns"
}

public enum TechnologyDescriptions {
    public static func description(for itemId: String) -> String {
        guard let item = TechnologyItem(rawValue: itemId) else {
            return defaultDescription
        }
        return descriptions[item] ?? defaultDescription
    }

    private static let defaultDescription = """
        This technology is used throughout the demo app to showcase modern iOS development practices.
        """

    private static let descriptions: [TechnologyItem: String] = [
        .asyncAwait: asyncAwaitDescription,
        .combine: combineDescription,
        .swiftUI: swiftUIDescription,
        .coordinator: coordinatorDescription,
        .mvvm: mvvmDescription,
        .spm: spmDescription,
        .serviceLocator: serviceLocatorDescription,
        .protocolOriented: protocolDescription,
        .featureToggles: featureTogglesDescription,
        .osLog: osLogDescription,
        .swift6: swift6Description,
        .swiftTesting: swiftTestingDescription,
        .snapshotTesting: snapshotDescription,
        .accessibility: accessibilityDescription,
        .deploymentTarget: deploymentTargetDescription,
        .concurrencyPatterns: concurrencyPatternsDescription
    ]

    // MARK: - Descriptions

    private static let asyncAwaitDescription = """
        This demo uses Swift's modern async/await for all asynchronous operations:

        • Data loading with simulated network delays
        • Pull-to-refresh using SwiftUI's .refreshable modifier
        • Task-based initialization in ViewModels
        • Structured concurrency with Task { } blocks

        Example from HomeViewModel:
        ```swift
        public func loadFeaturedItems() async {
            try? await Task.sleep(nanoseconds: delay)
            featuredItems = FeaturedItem.allCarouselSets
        }
        ```
        """

    private static let combineDescription = """
        Combine framework powers the reactive data flow throughout the app:

        • @Published properties for automatic UI updates
        • Debounced search input (600ms) in Items screen
        • Feature toggle change notifications
        • Favorites state synchronization across views
        • Scene lifecycle observation

        Example from ItemsViewModel:
        ```swift
        $searchText
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .sink { self.performSearch() }
            .store(in: &cancellables)
        ```
        """

    private static let swiftUIDescription = """
        SwiftUI provides the entire UI and navigation layer:

        • All views built with SwiftUI (HomeView, ItemsView, etc.)
        • NavigationStack + NavigationPath for programmatic navigation
        • @ObservedObject for ViewModel binding
        • Modern modifiers: .refreshable, .swipeActions, .searchable

        Navigation:
        ```swift
        NavigationStack(path: $coordinator.homePath) {
            HomeView(viewModel: viewModel)
                .navigationDestination(for: FeaturedItem.self) { item in
                    DetailView(viewModel: DetailViewModel(item: item))
                }
        }
        ```
        """

    private static let coordinatorDescription = """
        A single AppCoordinator manages all navigation:

        • ObservableObject owning NavigationPath per tab
        • Programmatic push via path.append()
        • Modal presentation via @Published booleans
        • ViewModels receive navigation closures, not coordinator refs

        Flow:
        View → ViewModel.onShowDetail?(item)
             → AppCoordinator.homePath.append(item)
             → NavigationStack picks up via .navigationDestination
        """

    private static let mvvmDescription = """
        MVVM architecture ensures clean separation of concerns:

        • View: Pure UI (SwiftUI) - no business logic
        • ViewModel: Business logic, state, data transformation
        • Model: Data structures and protocols

        Each screen follows this pattern:
        HomeView (@ObservedObject viewModel)
            ↓ binds to
        HomeViewModel (@Published state)
            ↓ uses
        Services (Network, Favorites, etc.)

        ViewModels are @MainActor for thread safety.
        """

    private static let spmDescription = """
        The app is modularized into 6 Swift packages:

        • Core - ServiceLocator, utilities
        • Model - Data models, protocols
        • Services - Concrete implementations
        • ViewModel - Business logic
        • UI - SwiftUI views
        • Coordinator - Navigation logic

        Dependency graph:
        ```
        FunApp → Coordinator → UI → ViewModel → Model → Core
          └────→ Services ─────────────────────→┘
        ```

        Benefits:
        • Clear dependency boundaries
        • Faster incremental builds
        • Enforced architecture layers
        • Easy to test in isolation
        """

    private static let serviceLocatorDescription = """
        Custom dependency injection using ServiceLocator pattern:

        Registration (in Session.activate):
        ```swift
        ServiceLocator.shared.register(
            NetworkServiceImpl(),
            for: .network
        )
        ```

        Resolution via property wrapper:
        ```swift
        @Service(.favorites)
        private var favoritesService: FavoritesServiceProtocol
        ```

        This enables easy mocking for tests while keeping injection simple.
        """

    private static let protocolDescription = """
        All services are protocol-based for testability:

        Protocol (in Model package):
        ```swift
        protocol FavoritesServiceProtocol {
            var favorites: Set<String> { get }
            func toggleFavorite(_ itemId: String)
        }
        ```

        Implementation (in Services package):
        ```swift
        class DefaultFavoritesService: FavoritesServiceProtocol
        ```

        Mock (for testing):
        ```swift
        class MockFavoritesService: FavoritesServiceProtocol
        ```
        """

    private static let featureTogglesDescription = """
        Runtime feature flags with reactive updates:

        • Persisted via UserDefaults
        • Combine publisher for cross-component sync
        • Toggle carousel visibility in Settings

        Usage:
        ```swift
        featureToggleService.featuredCarouselPublisher
            .sink { newValue in self.isCarouselEnabled = newValue }
            .store(in: &cancellables)
        ```

        Try it: Go to Settings → Toggle "Featured Carousel"
        """

    private static let osLogDescription = """
        Structured logging using Apple's OSLog:

        ```swift
        @Service(.logger) private var logger: LoggerService

        logger.log("Item selected: \\(item.title)")
        logger.log("Error occurred", level: .error, category: .network)
        ```

        Log levels: .debug, .info, .warning, .error, .fault
        Categories: auth, network, ui, data

        View logs in Console.app with subsystem filter.
        """

    private static let swift6Description = """
        Built with Swift 6 and strict concurrency:

        • @MainActor on all ViewModels and Services
        • Sendable conformance on data models
        • Structured concurrency with async/await
        • No data races - compiler enforced

        Example:
        ```swift
        @MainActor
        public class HomeViewModel: ObservableObject {
            // All UI-related code is main-thread safe
        }

        public struct FeaturedItem: Sendable {
            // Safe to pass across concurrency domains
        }
        ```
        """

    private static let swiftTestingDescription = """
        Modern Swift Testing framework for unit tests:

        ```swift
        @Suite("DefaultFavoritesService Tests")
        @MainActor
        struct DefaultFavoritesServiceTests {

            @Test("toggleFavorite adds item when not favorited")
            func testToggleFavoriteAdds() async {
                let service = DefaultFavoritesService()
                service.toggleFavorite( "item3")
                #expect(service.isFavorited("item3") == true)
            }
        }
        ```

        Benefits over XCTest: cleaner syntax, better assertions, parallel execution.
        """

}
